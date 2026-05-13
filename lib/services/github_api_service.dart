import 'dart:convert';

import 'package:http/http.dart' as http;

class GitHubApiException implements Exception {
  GitHubApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'GitHubApiException($statusCode): $message';
}

class GitHubUser {
  const GitHubUser({required this.login});

  final String login;
}

class GitHubRepo {
  const GitHubRepo({
    required this.name,
    required this.fullName,
    required this.isPrivate,
  });

  final String name;
  final String fullName;
  final bool isPrivate;
}

class GitHubCommitResult {
  const GitHubCommitResult({
    required this.commitSha,
    required this.contentSha,
    required this.created,
  });

  final String commitSha;
  final String contentSha;
  final bool created;
}

class GitHubApiService {
  GitHubApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<GitHubUser> getAuthenticatedUser(String token) async {
    final uri = Uri.https('api.github.com', '/user');
    final response = await _client.get(uri, headers: _headers(token));
    _ensureSuccess(response);
    final data = _decodeMap(response.body);
    return GitHubUser(login: data['login'] as String);
  }

  Future<List<GitHubRepo>> listRepos(String token) async {
    final uri = Uri.https('api.github.com', '/user/repos', {
      'per_page': '100',
      'sort': 'updated',
    });
    final response = await _client.get(uri, headers: _headers(token));
    _ensureSuccess(response);
    final data = _decodeList(response.body);
    return data
        .map((repo) {
          final map = repo as Map<String, dynamic>;
          return GitHubRepo(
            name: map['name'] as String,
            fullName: map['full_name'] as String,
            isPrivate: map['private'] as bool? ?? false,
          );
        })
        .toList();
  }

  Future<GitHubRepo> createRepo(String token, String name) async {
    final uri = Uri.https('api.github.com', '/user/repos');
    final response = await _client.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({
        'name': name,
        'private': false,
        'auto_init': true,
      }),
    );
    _ensureSuccess(response);
    final data = _decodeMap(response.body);
    return GitHubRepo(
      name: data['name'] as String,
      fullName: data['full_name'] as String,
      isPrivate: data['private'] as bool? ?? false,
    );
  }

  Future<GitHubCommitResult> upsertFile({
    required String token,
    required String owner,
    required String repo,
    required String path,
    required String content,
    required String message,
    required String branch,
  }) async {
    final sha = await _getFileSha(
      token: token,
      owner: owner,
      repo: repo,
      path: path,
      branch: branch,
    );

    final uri = Uri.https('api.github.com', '/repos/$owner/$repo/contents/$path');
    final body = <String, dynamic>{
      'message': message,
      'content': base64Encode(utf8.encode(content)),
      'branch': branch,
    };
    if (sha != null) {
      body['sha'] = sha;
    }

    final response = await _client.put(
      uri,
      headers: _headers(token),
      body: jsonEncode(body),
    );
    _ensureSuccess(response);
    final data = _decodeMap(response.body);
    final commit = data['commit'] as Map<String, dynamic>;
    final contentData = data['content'] as Map<String, dynamic>;

    return GitHubCommitResult(
      commitSha: commit['sha'] as String,
      contentSha: contentData['sha'] as String,
      created: sha == null,
    );
  }

  Future<String?> _getFileSha({
    required String token,
    required String owner,
    required String repo,
    required String path,
    required String branch,
  }) async {
    final uri = Uri.https('api.github.com', '/repos/$owner/$repo/contents/$path', {
      'ref': branch,
    });
    final response = await _client.get(uri, headers: _headers(token));
    if (response.statusCode == 404) {
      return null;
    }
    _ensureSuccess(response);
    final data = _decodeMap(response.body);
    return data['sha'] as String?;
  }

  Map<String, String> _headers(String token) {
    return {
      'Authorization': 'token $token',
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
    };
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    final message = _tryExtractMessage(response.body) ?? 'Request failed';
    throw GitHubApiException(response.statusCode, message);
  }

  Map<String, dynamic> _decodeMap(String body) {
    final decoded = jsonDecode(body);
    return decoded as Map<String, dynamic>;
  }

  List<dynamic> _decodeList(String body) {
    final decoded = jsonDecode(body);
    return decoded as List<dynamic>;
  }

  String? _tryExtractMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['message'] as String?;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
