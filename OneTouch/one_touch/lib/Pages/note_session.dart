import 'package:flutter/material.dart';
import 'package:one_touch/Objects/note.dart';
import '../Objects/template.dart';



/*
  To do: 
    1. build the two columns layout
        1a. left column: note display (scrollable if needed)
        1b. right column: note input area (different input types based on note type)
    
 */
// Andrew test note objects

NumberScaleNote note1 = new NumberScaleNote(
  noteType: NoteType.numberScale,
  question: "On a scale of 0-10, how are you feeling today?",
  minValue: 0,
  maxValue: 10,
  step: 1,
  minLabel: "Very Bad",
  maxLabel: "Excellent",
);

SingleChoiceNote note2 = new SingleChoiceNote(
  noteType: NoteType.singleChoice,
  question: "What is your current mood?",
  options: ["Happy", "Sad", "Angry", "Anxious", "Excited"],
);

MultipleChoiceNote note3 = new MultipleChoiceNote(
  noteType: NoteType.multipleChoice,
  question: "Which of the following symptoms are you experiencing?",
  options: ["Headache", "Nausea", "Fatigue", "Dizziness", "Cough"],
  maxSelections: 3,
);

List<Note> notesList = [note1, note2, note3];

class NoteSession extends StatelessWidget {
  final Template template;

  const NoteSession({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Note Session')),
      body: note3.toGui()
    );
  }
}
