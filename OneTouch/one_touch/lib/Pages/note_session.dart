import 'package:flutter/material.dart';
import 'package:one_touch/Objects/note.dart';
import '../Objects/session.dart';

/*
  NoteSession now accepts a Session object which tells this page what to show.
  It renders a list of pages from the session. Tapping a page shows the notes
  on that page.
*/

class NoteSession extends StatelessWidget {
  final Session session;

  const NoteSession({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Note Session')),
      body: session.length == 0
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No pages in this session'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    child: const Text('Back to Home Page'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: session.length,
              itemBuilder: (context, pageIndex) {
                final page = session.getAt(pageIndex)!;
                final title = 'Page ${pageIndex + 1}';
                return ListTile(
                  title: Text(title),
                  subtitle: Text('${page.length} notes'),
                  onTap: () {
                    // Show a simple dialog listing the note questions for now.
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(title),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: page.length,
                            itemBuilder: (context, noteIndex) {
                              final note = page.getAt(noteIndex)!;
                              return NoteWidget(note: note);
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
