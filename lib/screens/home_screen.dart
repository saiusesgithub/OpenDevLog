import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controllers/journal_editor_controller.dart';
import '../navigation/app_tabs.dart';
import '../widgets/section_card.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
    this.onNavigate,
    DateTime? date,
    this.showNavigationActions = true,
    this.onBack,
  })  : date = date ?? DateTime.now(),
        assert(showNavigationActions ? onNavigate != null : true);

  final ValueChanged<AppTab>? onNavigate;
  final DateTime date;
  final bool showNavigationActions;
  final VoidCallback? onBack;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  JournalEditorController? _controller;
  TextEditingController? _textController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadController();
  }

  Future<void> _loadController() async {
    final controller = await JournalEditorController.create(widget.date);
    if (!mounted) {
      controller.dispose();
      return;
    }
    final textController =
        TextEditingController(text: controller.draftText);
    textController.addListener(() {
      controller.updateText(textController.text);
    });

    setState(() {
      _controller = controller;
      _textController = textController;
      _isLoading = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller?.forceSave();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _textController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _saveAndNavigate(AppTab tab) async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    await controller.forceSave();
    if (!mounted) {
      return;
    }
    final onNavigate = widget.onNavigate;
    if (onNavigate == null) {
      return;
    }
    onNavigate(tab);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final controller = _controller;
    final textController = _textController;
    if (controller == null || textController == null) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final editorHeight = math.max(320.0, screenHeight * 0.45);
    final dateLabel = _formatDate(widget.date);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateLabel, style: textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text('Streak: 7 days', style: textTheme.bodyMedium),
                  ],
                ),
              ),
              _SaveStatusChip(controller: controller),
            ],
          ),
          const SizedBox(height: 20),
          SectionCard(
            title: 'Rough diary',
            trailing: Text(
              'Autosave on pause',
              style: textTheme.bodySmall,
            ),
            child: SizedBox(
              height: editorHeight,
              child: TextField(
                controller: textController,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Start writing your devlog...'
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.showNavigationActions
                ? [
                    FilledButton.icon(
                      onPressed: () => _saveAndNavigate(AppTab.summary),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Generate Summary'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _saveAndNavigate(AppTab.preview),
                      icon: const Icon(Icons.preview),
                      label: const Text('Preview Markdown'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => controller.forceSave(),
                      icon: const Icon(Icons.upload),
                      label: const Text('Push to GitHub'),
                    ),
                    TextButton.icon(
                      onPressed: () => widget.onNavigate?.call(AppTab.entries),
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Previous Entries'),
                    ),
                    TextButton.icon(
                      onPressed: () => widget.onNavigate?.call(AppTab.settings),
                      icon: const Icon(Icons.tune),
                      label: const Text('Settings'),
                    ),
                  ]
                : [
                    OutlinedButton.icon(
                      onPressed: () async {
                        await controller.forceSave();
                        widget.onBack?.call();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to entries'),
                    ),
                  ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = months[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }
}

class _SaveStatusChip extends StatelessWidget {
  const _SaveStatusChip({required this.controller});

  final JournalEditorController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final colorScheme = Theme.of(context).colorScheme;
        final dotColor = _statusColor(colorScheme);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colorScheme.outline.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: dotColor),
              const SizedBox(width: 8),
              Text(controller.statusLabel),
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(ColorScheme colorScheme) {
    switch (controller.saveState) {
      case SaveState.failed:
        return colorScheme.error;
      case SaveState.unsaved:
        return colorScheme.tertiary;
      case SaveState.saving:
        return colorScheme.primary;
      case SaveState.saved:
      case SaveState.idle:
        return colorScheme.primary;
    }
  }
}
