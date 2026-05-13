import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../navigation/app_routes.dart';
import '../repositories/local_settings_repository.dart';
import '../services/github_api_service.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _tokenController = TextEditingController();
  final _repoController = TextEditingController(text: 'open-devlog');
  final _branchController = TextEditingController(text: 'main');
  final _providerController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();

  final _githubService = GitHubApiService();
  LocalSettingsRepository? _settingsRepository;

  bool _isLoading = true;
  bool _isFetching = false;
  bool _isCreating = false;
  bool _isSaving = false;
  String? _username;
  String? _selectedRepo;
  List<GitHubRepo> _repos = [];

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
    _repoController.text = settings.selectedRepo ?? _repoController.text;
    _branchController.text = settings.selectedBranch;
    _providerController.text = settings.aiProvider ?? '';
    _apiKeyController.text = settings.aiApiKey ?? '';
    _modelController.text = settings.aiModel ?? '';
    _username = settings.githubUsername;
    _selectedRepo = settings.selectedRepo;

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
    super.dispose();
  }

  Future<void> _fetchRepos() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      _showMessage('Paste a GitHub token first.');
      return;
    }

    setState(() {
      _isFetching = true;
    });

    try {
      final user = await _githubService.getAuthenticatedUser(token);
      final repos = await _githubService.listRepos(token);
      if (!mounted) {
        return;
      }
      setState(() {
        _username = user.login;
        _repos = repos;
        _selectedRepo ??= repos.isNotEmpty ? repos.first.name : null;
      });
      _showMessage('Repos loaded for ${user.login}.');
    } catch (error) {
      _showMessage('GitHub error: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }

  Future<void> _createRepo() async {
    final token = _tokenController.text.trim();
    final name = _repoController.text.trim();
    if (token.isEmpty) {
      _showMessage('Paste a GitHub token first.');
      return;
    }
    if (name.isEmpty) {
      _showMessage('Enter a repo name.');
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final repo = await _githubService.createRepo(token, name);
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedRepo = repo.name;
        _repos = [..._repos, repo];
      });
      _showMessage('Repo ${repo.name} created.');
    } catch (error) {
      _showMessage('Could not create repo: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _saveAndContinue() async {
    final repository = _settingsRepository;
    if (repository == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final settings = AppSettings(
      githubToken: _tokenController.text.trim(),
      githubUsername: _username,
      selectedRepo: _selectedRepo ?? _repoController.text.trim(),
      selectedBranch: _branchController.text.trim().isEmpty
          ? 'main'
          : _branchController.text.trim(),
      aiProvider: _providerController.text.trim(),
      aiApiKey: _apiKeyController.text.trim(),
      aiModel: _modelController.text.trim(),
    );

    try {
      await repository.saveSettings(settings);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(AppRoutes.app);
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
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Open DevLog'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('First-time setup', style: textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Connect GitHub, add your AI key, and choose a repo. No data is sent until you push.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Text('Step 1: Connect GitHub',
                        style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tokenController,
                      decoration: const InputDecoration(
                        labelText: 'GitHub Personal Access Token',
                        hintText: 'ghp_...'
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _branchController,
                      decoration: const InputDecoration(
                        labelText: 'Default branch',
                        hintText: 'main',
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_username != null)
                      Text('Signed in as $_username',
                          style: textTheme.bodySmall),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: _isFetching ? null : _fetchRepos,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Fetch repos'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _isCreating ? null : _createRepo,
                          icon: const Icon(Icons.add),
                          label: const Text('Create repo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_repos.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: _selectedRepo,
                        items: _repos
                            .map((repo) => DropdownMenuItem(
                                  value: repo.name,
                                  child: Text(repo.name),
                                ))
                            .toList(),
                        decoration: const InputDecoration(
                          labelText: 'Select existing repo',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedRepo = value;
                          });
                        },
                      )
                    else
                      Text('No repos loaded yet.',
                          style: textTheme.bodySmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _repoController,
                      decoration: const InputDecoration(
                        labelText: 'New repo name',
                        hintText: 'open-devlog',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Step 2: Add AI API key',
                        style: textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _providerController,
                      decoration: const InputDecoration(
                        labelText: 'AI provider',
                        hintText: 'OpenAI / Gemini / Groq',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'API key',
                        hintText: 'sk-...'
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Model name',
                        hintText: 'gpt-4.1-mini',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        FilledButton(
                          onPressed: _isSaving ? null : _saveAndContinue,
                          child: const Text('Start journaling'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.app);
                          },
                          child: const Text('Skip for now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
