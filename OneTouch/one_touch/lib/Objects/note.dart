import 'package:flutter/material.dart';

enum NoteType {
  nullType,
  numberScale,
  text,
  multipleChoice,
  singleChoice
}

class Note {
  Enum noteType = NoteType.nullType;
  String question = "What kind of note is this?";

  Note({required this.noteType, required this.question});
}

class NoteWidget extends StatelessWidget{
  final Note note;

  const NoteWidget({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class NumberScaleNote extends Note{
  int min = 0;
  int max = 10;
  int step = 1;
  String minLabel = "Low";
  String maxLabel = "High";  

  NumberScaleNote({
    required Enum noteType,
    required String question,
    required this.min,
    required this.max,
    required this.step,
    required this.minLabel,
    required this.maxLabel
  }) : super(noteType: noteType, question: question);

  // widget to construct and display the note in the app

  // Implementation for building the number scale widget
  buildNumberScaleWidget() {
    return Slider(
      value: min.toDouble(),
      min: min.toDouble(),
      max: max.toDouble(),
      divisions: ((max - min) ~/ step),
      label: minLabel,
      onChanged: (double value) {
        // Handle the slider value change, how to pass this along?
      },
    );
  }
}

/*
  MultipleChoiceNotes should have a different physical shape than SingleChoiceNotes
  to make it easier for users to distinguish between the two types of notes
 */
class MultipleChoiceNote extends Note{
  List<String> options = [];
  int maxSelections = 3;

  MultipleChoiceNote({
    required Enum noteType,
    required String question,
    required this.options,
    required this.maxSelections
  }) : super(noteType: noteType, question: question);

  // widget to construct and display the note in the app

  buildMultipleChoiceWidget() {
    return Column(
      children: options.map((option) {
        return CheckboxListTile(
          title: Text(option),
          value: false, // This should be linked to the actual selection state
          onChanged: (bool? value) {
            // Handle the checkbox state change
          },
        );
      }).toList(),
    );
  }
  
}

class SingleChoiceNote extends Note{
  List<String> options = [];

  SingleChoiceNote({
    required Enum noteType,
    required String question,
    required this.options
  }) : super(noteType: noteType, question: question);

  // widget to construct and display the note in the app
}

