import 'package:flutter/material.dart';
import 'package:one_touch/Objects/note.dart';
import '../Objects/template.dart';


/*
  To do: 
    1. make note widgets actually show different types of notes
    2. make it so we can answer the notes, not just view them
    3. store note answers back into the Session object
      3a. need to modify the Session object to hold answers
      3b. modify NoteSession to save answers
 */
class NoteSession extends StatelessWidget {
  final Template template;

  const NoteSession({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Note Session')),
      );
  }
}
