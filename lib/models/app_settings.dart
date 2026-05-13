class AppSettings {
  const AppSettings({
    this.githubToken,
    this.githubUsername,
    this.selectedRepo,
    this.selectedBranch = 'main',
    this.aiProvider,
    this.aiApiKey,
    this.aiModel,
    this.autoCommitEnabled = false,
    this.autoCommitTime = '23:30',
    this.themeMode = 'dark',
  });

  final String? githubToken;
  final String? githubUsername;
  final String? selectedRepo;
  final String selectedBranch;
  final String? aiProvider;
  final String? aiApiKey;
  final String? aiModel;
  final bool autoCommitEnabled;
  final String autoCommitTime;
  final String themeMode;

  factory AppSettings.initial() => const AppSettings();

  AppSettings copyWith({
    String? githubToken,
    String? githubUsername,
    String? selectedRepo,
    String? selectedBranch,
    String? aiProvider,
    String? aiApiKey,
    String? aiModel,
    bool? autoCommitEnabled,
    String? autoCommitTime,
    String? themeMode,
  }) {
    return AppSettings(
      githubToken: githubToken ?? this.githubToken,
      githubUsername: githubUsername ?? this.githubUsername,
      selectedRepo: selectedRepo ?? this.selectedRepo,
      selectedBranch: selectedBranch ?? this.selectedBranch,
      aiProvider: aiProvider ?? this.aiProvider,
      aiApiKey: aiApiKey ?? this.aiApiKey,
      aiModel: aiModel ?? this.aiModel,
      autoCommitEnabled: autoCommitEnabled ?? this.autoCommitEnabled,
      autoCommitTime: autoCommitTime ?? this.autoCommitTime,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'githubToken': githubToken,
      'githubUsername': githubUsername,
      'selectedRepo': selectedRepo,
      'selectedBranch': selectedBranch,
      'aiProvider': aiProvider,
      'aiApiKey': aiApiKey,
      'aiModel': aiModel,
      'autoCommitEnabled': autoCommitEnabled,
      'autoCommitTime': autoCommitTime,
      'themeMode': themeMode,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      githubToken: json['githubToken'] as String?,
      githubUsername: json['githubUsername'] as String?,
      selectedRepo: json['selectedRepo'] as String?,
      selectedBranch: json['selectedBranch'] as String? ?? 'main',
      aiProvider: json['aiProvider'] as String?,
      aiApiKey: json['aiApiKey'] as String?,
      aiModel: json['aiModel'] as String?,
      autoCommitEnabled: json['autoCommitEnabled'] as bool? ?? false,
      autoCommitTime: json['autoCommitTime'] as String? ?? '23:30',
      themeMode: json['themeMode'] as String? ?? 'dark',
    );
  }
}
