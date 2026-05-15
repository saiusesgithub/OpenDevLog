import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class AiSummaryException implements Exception {
  AiSummaryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AiSummaryService {
  AiSummaryService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> generate({
    required String roughDiary,
    required String provider,
    required String apiKey,
    required String model,
  }) async {
    final prompt = _buildPrompt(roughDiary);

    if (_isGemini(provider)) {
      return _generateGemini(
        apiKey: apiKey,
        model: model,
        prompt: prompt,
      );
    } else if (_isOpenAi(provider)) {
      return _generateOpenAi(
        apiKey: apiKey,
        model: model,
        prompt: prompt,
      );
    }

    throw AiSummaryException('Unsupported AI provider: $provider');
  }

  Future<String> _generateGemini({
    required String apiKey,
    required String model,
    required String prompt,
  }) async {
    if (apiKey.isEmpty) {
      throw AiSummaryException('Missing Gemini API key.');
    }

    final modelName = await _resolveGeminiModel(
      apiKey: apiKey,
      requestedModel: model,
    );

    try {
      final generativeModel = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.3,
          maxOutputTokens: 1200,
        ),
      );

      final content = [Content.text(prompt)];
      final response = await generativeModel.generateContent(content);
      
      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        throw AiSummaryException('Gemini returned empty text.');
      }

      return text.trim();
    } on GenerativeAIException catch (e) {
      throw AiSummaryException('Gemini Error: ${e.message}');
    } catch (e) {
      throw AiSummaryException('Gemini request failed: $e');
    }
  }

  Future<String> _generateOpenAi({
    required String apiKey,
    required String model,
    required String prompt,
  }) async {
    if (apiKey.isEmpty) {
      throw AiSummaryException('Missing OpenAI API key.');
    }
    
    final modelName = model.isEmpty ? 'gpt-3.5-turbo' : model;

    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');

    try {
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': modelName,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.3,
          'max_tokens': 1200,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = _extractOpenAiError(response.body);
        throw AiSummaryException(error ?? 'OpenAI request failed (${response.statusCode}).');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = decoded['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw AiSummaryException('OpenAI returned no choices.');
      }
      final firstChoice = choices.first as Map<String, dynamic>;
      final message = firstChoice['message'] as Map<String, dynamic>?;
      final text = message?['content'] as String?;

      if (text == null || text.trim().isEmpty) {
        throw AiSummaryException('OpenAI returned empty text.');
      }

      return text.trim();
    } catch (e) {
      if (e is AiSummaryException) rethrow;
      throw AiSummaryException('OpenAI request failed: $e');
    }
  }

  bool _isGemini(String provider) {
    final normalized = provider.trim().toLowerCase();
    return normalized.contains('gemini') || normalized.contains('google');
  }

  bool _isOpenAi(String provider) {
    final normalized = provider.trim().toLowerCase();
    return normalized.contains('openai') || normalized.contains('gpt');
  }

  String _normalizeGeminiModel(String model) {
    final trimmed = model.trim();
    if (trimmed.isEmpty) {
      return 'gemini-1.5-flash';
    }

    final lower = trimmed.toLowerCase();
    if (lower == 'gemini-1.5-flash' || lower == 'gemini-1.5-flash-latest') {
      return 'gemini-1.5-flash';
    }
    if (lower == 'gemini-1.5-pro' || lower == 'gemini-1.5-pro-latest') {
      return 'gemini-1.5-pro';
    }
    if (lower.contains('flash') && !lower.contains('gemini')) {
      return 'gemini-1.5-flash';
    }
    if (lower.contains('pro') && !lower.contains('gemini')) {
      return 'gemini-1.5-pro';
    }

    return lower.replaceAll(' ', '-');
  }

  Future<String> _resolveGeminiModel({
    required String apiKey,
    required String requestedModel,
  }) async {
    final normalized = _normalizeGeminiModel(requestedModel);
    final available = await _listGeminiModels(apiKey);

    if (available.isEmpty) {
      return normalized;
    }
    if (available.contains(normalized)) {
      return normalized;
    }

    final preferred = _pickPreferredGeminiModel(available);
    return preferred ?? available.first;
  }

  Future<List<String>> _listGeminiModels(String apiKey) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey',
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return [];
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final models = decoded['models'] as List<dynamic>?;
      if (models == null) {
        return [];
      }

      final result = <String>[];
      for (final model in models) {
        if (model is! Map<String, dynamic>) {
          continue;
        }
        final name = model['name'] as String?;
        final methods = model['supportedGenerationMethods'] as List<dynamic>?;
        if (name == null || methods == null) {
          continue;
        }
        final supportsGenerate = methods
            .map((method) => method.toString())
            .contains('generateContent');
        if (!supportsGenerate) {
          continue;
        }

        result.add(name.replaceFirst('models/', ''));
      }

      return result;
    } catch (_) {
      return [];
    }
  }

  String? _pickPreferredGeminiModel(List<String> models) {
    String? pick(bool Function(String model) predicate) {
      for (final model in models) {
        if (predicate(model)) {
          return model;
        }
      }
      return null;
    }

    return pick((model) => model.contains('1.5-flash')) ??
        pick((model) => model.contains('flash')) ??
        pick((model) => model.contains('1.5-pro')) ??
        pick((model) => model.contains('pro'));
  }

  String _buildPrompt(String roughDiary) {
    return '''You are summarizing a developer's daily devlog.

Rules:
- Do not expose highly personal or private details.
- Preserve concrete facts, timelines, and outcomes.
- Use the exact markdown-friendly headings below.

Output format:
One-Line Summary:
<single sentence>

Detailed Summary:
- <bullet>
- <bullet>

Timeline:
- Morning: <text>
- Afternoon: <text>
- Evening: <text>

Time Allocation:
| Category | Time |
| --- | ---: |
| Coding | |
| Learning | |
| Planning | |
| Wasted Time | |

Wins:
- <bullet>

Wasted Time / Distractions:
- <bullet>

Improvements For Tomorrow:
- <bullet>

Tags:
- #tag

Rough diary:
"""
$roughDiary
"""
''';
  }

  String? _extractOpenAiError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'] as Map<String, dynamic>?;
        return error?['message'] as String?;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
