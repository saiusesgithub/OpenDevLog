import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../repositories/local_settings_repository.dart';
import '../widgets/section_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _tokenController = TextEditingController();
  final _repoController = TextEditingController();
  final _branchController = TextEditingController(text: 'main');
  final _providerController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();
  final _commitTimeController = TextEditingController(text: '23:30');

  LocalSettingsRepository? _settingsRepository;
  String? _githubUsername;
  bool _autoCommitEnabled = false;
  bool _darkThemeEnabled = true;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final repository = LocalSettingsRepository(prefs);
    final settings = await repository.getSettings();

    _settingsRepository = repository;
    _tokenController.text = settings.githubToken ?? '';
    _repoController.text = settings.selectedRepo ?? '';
    _branchController.text = settings.selectedBranch;
    _providerController.text = settings.aiProvider ?? '';
    _apiKeyController.text = settings.aiApiKey ?? '';
    _modelController.text = settings.aiModel ?? '';
    _commitTimeController.text = settings.autoCommitTime;
    _githubUsername = settings.githubUsername;
    _autoCommitEnabled = settings.autoCommitEnabled;
    _darkThemeEnabled = settings.themeMode == 'dark';

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _repoController.dispose();
    _branchController.dispose();
    _providerController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    _commitTimeController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final repository = _settingsRepository;
    if (repository == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final settings = AppSettings(
      githubToken: _tokenController.text.trim(),
      githubUsername: _githubUsername,
      selectedRepo: _repoController.text.trim(),
      selectedBranch: _branchController.text.trim().isEmpty
          ? 'main'
          : _branchController.text.trim(),
      aiProvider: _providerController.text.trim(),
      aiApiKey: _apiKeyController.text.trim(),
      aiModel: _modelController.text.trim(),
      autoCommitEnabled: _autoCommitEnabled,
      autoCommitTime: _commitTimeController.text.trim().isEmpty
          ? '23:30'
          : _commitTimeController.text.trim(),
      themeMode: _darkThemeEnabled ? 'dark' : 'light',
    );

    try {
      await repository.saveSettings(settings);
      _showMessage('Settings saved.');
    } catch (error) {
      _showMessage('Could not save settings: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          SectionCard(
            title: 'GitHub',
            child: Column(
              children: [
                TextField(
                  controller: _tokenController,
                  decoration: const InputDecoration(
                    labelText: 'Personal Access Token',
                    hintText: 'ghp_...'
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _repoController,
                  decoration: const InputDecoration(
                    labelText: 'Repository',
                    hintText: 'open-devlog',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _branchController,
                  decoration: const InputDecoration(
                    labelText: 'Branch',
                    hintText: 'main',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'AI provider',
            child: Column(
              children: [
                TextField(
                  controller: _providerController,
                  decoration: const InputDecoration(
                    labelText: 'Provider',
                    hintText: 'OpenAI / Gemini / Groq',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _apiKeyController,
                  decoration: const InputDecoration(
                    labelText: 'API key',
                    hintText: 'sk-...'
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _modelController,
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    hintText: 'gpt-4.1-mini',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Auto commit',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _autoCommitEnabled,
                  onChanged: (value) {
                    setState(() {
                      _autoCommitEnabled = value;
                    });
                  },
                  title: const Text('Auto commit enabled'),
                  subtitle: const Text('Only pushes when summary exists.'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commitTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Commit time',
                    hintText: '23:30',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Appearance',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _darkThemeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkThemeEnabled = value;
                    });
                  },
                  title: const Text('Dark theme'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export local data'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _isSaving ? null : _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('Save settings'),
          ),
        ],
      ),
    );
  }
}
