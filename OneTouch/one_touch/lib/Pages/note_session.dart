import 'dart:async'; // Timer

import 'package:flutter/material.dart';
import 'package:one_touch/Pages/session_summary.dart';
import 'package:one_touch/Pages/settings_page.dart';
import '../Objects/template.dart';

class NoteSession extends StatefulWidget {
  final Template template;

  final void Function(List<Template>, String) saveTemplatesCallback;
  const NoteSession({
    super.key,
    required this.template,
    required this.saveTemplatesCallback,
  });

  @override
  State<NoteSession> createState() => _NoteSessionState();
}

class _NoteSessionState extends State<NoteSession> {
  late ValueNotifier<int?> selectedNotifier;
  final ScrollController _leftScrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _autoScrollEnabled = false;
  int _autoScrollDelayMs = 2000;

  @override
  void initState() {
    super.initState();
    // Preselect the first note (if any) so the UI shows content immediately.
    selectedNotifier =
        ValueNotifier<int?>(widget.template.notes.isNotEmpty ? 0 : null);
    _loadAutoScrollSettings();
  }

  Future<void> _loadAutoScrollSettings() async {
    _autoScrollEnabled =
        await AppSettings.instance.getAutoScrollEnabled(); // prefs flag
    _autoScrollDelayMs =
        await AppSettings.instance.getAutoScrollDelayMs(defaultValue: 2000);
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _leftScrollController.dispose();
    selectedNotifier.dispose();
    super.dispose();
  }

  void _startAutoScrollTimer() {
    if (!_autoScrollEnabled) return;
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer(
      Duration(milliseconds: _autoScrollDelayMs),
      _advanceAfterDelay,
    );
  }

  void _advanceAfterDelay() {
    if (!mounted) return;
    final notes = widget.template.notes;
    if (notes.isEmpty) return;

    final current = selectedNotifier.value ?? 0;
    if (current < notes.length - 1) {
      selectedNotifier.value = current + 1;
      _scrollToNote(current + 1);
    } else {
      _finishSession();
    }
  }

  void _finishSession() {
    widget.saveTemplatesCallback([widget.template], "save");
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionSummary(template: widget.template),
      ),
    );
  }

  void _scrollToNote(int index) {
    final itemHeight = 48.0; // Approximate height of each list item
    final padding = 30.0; // Extra padding for spacing
    final offset = (index * itemHeight) + padding;
    _leftScrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 125,
        leading: Container(
          margin: EdgeInsets.only(left: 20, top: 5, bottom: 5),
          child: FloatingActionButton.extended(
            elevation: 0,
            heroTag: 'exit',
            onPressed: () {
              // cancel changes and reset templates
              widget.saveTemplatesCallback([widget.template], "revert");
              Navigator.pop(context);
            },
            icon: const Icon(Icons.keyboard_return, color: Colors.white),
            label: const Text(
              'Exit',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            backgroundColor: Color.fromARGB(200, 11, 53, 99),
          ),
        ),
        centerTitle: true,
        title: Text(
          widget.template.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        actions: [
          FloatingActionButton.extended(
            elevation: 0,
            heroTag: 'save',
            onPressed: () {
              // cancel changes and reset templates
              widget.saveTemplatesCallback([widget.template], "save");
            },
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              'Save',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            backgroundColor: Color.fromARGB(255, 102, 153, 204),
          ),
          SizedBox(width: 20),
          FloatingActionButton.extended(
            elevation: 0,
            heroTag: 'delete',
            onPressed: () {
              // cancel changes and reset templates
              widget.saveTemplatesCallback([widget.template], "delete");
              Navigator.pop(context);
            },
            icon: const Icon(Icons.cancel, color: Colors.white),
            label: const Text(
              'Delete',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            backgroundColor: Color.fromARGB(200, 11, 53, 99),
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left panel - extracted to prevent full rebuild
                  _NoteListPanel(
                    notes: widget.template.notes,
                    selectedNotifier: selectedNotifier,
                    scrollController: _leftScrollController,
                  ),
                  // Right panel - only rebuilds when selected note changes
                  _NoteDisplayPanel(
                    template: widget.template,
                    selectedNotifier: selectedNotifier,
                    scrollController: _leftScrollController,
                    onSave: () =>
                        widget.saveTemplatesCallback([widget.template], "save"),
                    onInteract: _startAutoScrollTimer,
                    scrollToNote: _scrollToNote,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Left panel showing the list of notes - isolated to prevent rebuilds
class _NoteListPanel extends StatelessWidget {
  final List notes;
  final ValueNotifier<int?> selectedNotifier;
  final ScrollController scrollController;

  const _NoteListPanel({
    required this.notes,
    required this.selectedNotifier,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scrollbar(
          controller: scrollController,
          thumbVisibility: false,
          thickness: 6.0,
          radius: const Radius.circular(3),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ListView.separated(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return _NoteTile(
                  note: note,
                  index: index,
                  selectedNotifier: selectedNotifier,
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
            ),
          ),
        ),
      ),
    );
  }
}

/// Right panel showing the selected note - only rebuilds when selected changes
class _NoteDisplayPanel extends StatelessWidget {
  final Template template;
  final ValueNotifier<int?> selectedNotifier;
  final ScrollController scrollController;
  final VoidCallback onSave;
  final VoidCallback onInteract;
  final void Function(int) scrollToNote;

  const _NoteDisplayPanel({
    required this.template,
    required this.selectedNotifier,
    required this.scrollController,
    required this.onSave,
    required this.onInteract,
    required this.scrollToNote,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder<int?>(
        valueListenable: selectedNotifier,
        builder: (context, selected, _) {
          final notes = template.notes;
          final isLastNote = selected != null && selected == notes.length - 1;

          return Stack(
            children: [
              (selected == null)
                  ? const Center(child: Text('Select a note'))
                  : Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 150),
                          child: RepaintBoundary(
                            child: KeyedSubtree(
                              key: ValueKey(selected),
                              child: notes[selected!].toGui(
                                onInteract: onInteract,
                              ),
                            ),
                          ),
                        ),
                      ),
                ),
              const Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: VerticalDivider(width: 1),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: _ContinueButton(
                  isLastNote: isLastNote,
                  selected: selected,
                  notes: notes,
                  onSelectNext: (i) {
                    selectedNotifier.value = i;
                    scrollToNote(i);
                  },
                  onFinish: () {
                    onSave();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SessionSummary(template: template),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

}

/// Individual note tile with RepaintBoundary to isolate repaints
class _NoteTile extends StatelessWidget {
  final dynamic note;
  final int index;
  final ValueNotifier<int?> selectedNotifier;

  const _NoteTile({
    required this.note,
    required this.index,
    required this.selectedNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ValueListenableBuilder<int?>(
        valueListenable: selectedNotifier,
        builder: (context, selected, _) {
          final isSelected = selected == index;
          final secondaryContainer = Color.fromARGB(255, 102, 153, 204);
          final onSecondaryContainer = Colors.white;

          return ListTile(
            dense: true,
            title: Text(note.question),
            selected: isSelected,
            selectedTileColor: secondaryContainer,
            selectedColor: onSecondaryContainer,
            onTap: () => selectedNotifier.value = index,
          );
        },
      ),
    );
  }
}

/// Extracted continue button to isolate repaints from label changes
class _ContinueButton extends StatelessWidget {
  final bool isLastNote;
  final int? selected;
  final List notes;
  final Function(int) onSelectNext;
  final VoidCallback onFinish;

  const _ContinueButton({
    required this.isLastNote,
    required this.selected,
    required this.notes,
    required this.onSelectNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: 120,
        width: 160,
        child: FloatingActionButton.extended(
          elevation: 0,
          heroTag: 'continue',
          onPressed: () {
            if (notes.isEmpty) return;

            // if nothing selected yet, start with the first note
            if (selected == null) {
              onSelectNext(0);
              return;
            }

            // If at last note, finish
            if (isLastNote) {
              onFinish();
              return;
            }

            // Otherwise, go to next note
            if (selected! < notes.length - 1) {
              onSelectNext(selected! + 1);
            }
          },
          icon: const Icon(Icons.arrow_forward, color: Colors.white),
          label: Text(
            isLastNote ? 'Finish' : 'Next',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color.fromARGB(200, 11, 53, 99),
        ),
      ),
    );
  }
}
