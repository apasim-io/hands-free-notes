import 'package:flutter/material.dart';
import 'package:one_touch/Objects/note.dart';
import '../Objects/template.dart';


/*
  To do: 
    1. build the two columns layout
        1a. left column: note display (scrollable if needed)
        1b. right column: note input area (different input types based on note type)
    
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
