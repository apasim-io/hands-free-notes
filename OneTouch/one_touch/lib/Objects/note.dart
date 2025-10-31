import 'package:flutter/material.dart';

enum NoteType { nullType, numberScale, text, multipleChoice, singleChoice }

class Note {
  Enum noteType = NoteType.nullType;
  String question = "What kind of note is this?";

  Note({required this.noteType, required this.question});

  Note.fromJson(Map<String, dynamic> json)
    : noteType = NoteType.values.firstWhere(
        (e) => e.toString() == 'NoteType.${json['note_type']}',
        orElse: () => NoteType.nullType,
      ),
      question = json['question'] ?? 'No question';

  Map<String, dynamic> toJson() => {
    'note_type': noteType.toString(),
    'question': question
  };
}

class NumberScaleNote extends Note {
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
    required this.maxLabel,
  }) : super(noteType: noteType, question: question);

  NumberScaleNote.fromJson(Map<String, dynamic> json)
    : min = json['min_value'] ?? json['min'] ?? 0,
      max = json['max_value'] ?? json['max'] ?? 10,
      step = json['step'] ?? 1,
      minLabel = json['min_label'] ?? json['minLabel'] ?? 'Low',
      maxLabel = json['max_label'] ?? json['maxLabel'] ?? 'High',
      super.fromJson(json);

  @override
  Map<String, dynamic> toJson() => {
    'note_type': noteType.name,
    'question': question,
    'min_value': min,
    'max_value': max,
    'step': step,
    'min_label': minLabel,
    'max_label': maxLabel,
  };
}

/*
  MultipleChoiceNotes should have a different physical shape than SingleChoiceNotes
  to make it easier for users to distinguish between the two types of notes
 */
class MultipleChoiceNote extends Note {
  List<String> options = [];
  int maxSelections = 3;

  MultipleChoiceNote({
    required Enum noteType,
    required String question,
    required this.options,
    required this.maxSelections,
  }) : super(noteType: noteType, question: question);

  MultipleChoiceNote.fromJson(Map<String, dynamic> json)
    : options =
          (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      maxSelections = json['max_selections'] ?? 3,
      super.fromJson(json);

  @override
  Map<String, dynamic> toJson() => {
    'note_type': noteType.name,
    'question': question,
    'options': options
  };
}

class SingleChoiceNote extends Note {
  List<String> options = [];

  SingleChoiceNote({
    required Enum noteType,
    required String question,
    required this.options,
  }) : super(noteType: noteType, question: question);

  SingleChoiceNote.fromJson(Map<String, dynamic> json)
    : options =
          (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      super.fromJson(json);

  @override
  Map<String, dynamic> toJson() => {
    'note_type': noteType.name,
    'question': question,
    'options': options
  };
}

/*
  To do: 
    1. make note widgets actually show different types of notes, switch case?
 */

class NoteWidget extends StatefulWidget {
  final Note note;

  const NoteWidget({super.key, required this.note});

  @override
  State<NoteWidget> createState() => NoteWidgetState();
}

class NoteWidgetState extends State<NoteWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(child: Column(children: [Text(widget.note.question), Text(widget.note.noteType.toString())]));
  }
}
