import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'note.g.dart';

enum NoteType {
  @JsonValue("nullType") nullType, 
  @JsonValue("numberScale") numberScale,
  @JsonValue("text") text,
  @JsonValue("multipleChoice") multipleChoice,
  @JsonValue("singleChoice") singleChoice }

@JsonSerializable()
class Note {
  @JsonKey()
  NoteType noteType = NoteType.nullType;
  String question = "What kind of note is this?";

  Note({
    required this.noteType,
    required this.question
  });

  // Serialization
  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);

  Widget toGui(){ 
    return Container();
  }
}

@JsonSerializable()
class NumberScaleNote extends Note {
  int minValue = 0;
  int maxValue = 10;
  int step = 1;
  String minLabel = "Low";
  String maxLabel = "High";
  int? selection;

  int value = 0;

  NumberScaleNote({
    required NoteType noteType,
    required String question,
    required this.minValue,
    required this.maxValue,
    required this.step,
    required this.minLabel,
    required this.maxLabel,
  }): super(noteType: noteType, question: question);

  // Serialization
  factory NumberScaleNote.fromJson(Map<String, dynamic> json) => _$NumberScaleNoteFromJson(json);
  @override Map<String, dynamic> toJson() => _$NumberScaleNoteToJson(this);

  @override
  Container toGui(){ 
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Slider(
        value: value.toDouble(), 
        onChanged: onChanged,
        min: minValue.toDouble(),
        max: maxValue.toDouble(),
        divisions: ((maxValue - minValue) / step).round(),
        label: value.round().toString(),
      )
    );
    
    
  }

  void onChanged(double newValue){
    value = newValue.toInt();
  }

}

/*
  MultipleChoiceNotes should have a different physical shape than SingleChoiceNotes
  to make it easier for users to distinguish between the two types of notes
 */
@JsonSerializable()
class MultipleChoiceNote extends Note {
  List<String> options = [];
  int maxSelections = 3;
  List<int>? selection; // indices of selected options (nullable to handle missing/null JSON)

  MultipleChoiceNote({
    required NoteType noteType,
    required String question,
    required this.options,
    required this.maxSelections,
  }): super(noteType: noteType, question: question);

  // Serialization
  factory MultipleChoiceNote.fromJson(Map<String, dynamic> json) => _$MultipleChoiceNoteFromJson(json);
  @override Map<String, dynamic> toJson() => _$MultipleChoiceNoteToJson(this);

  // generate a square button for each option (returns a single Widget)
  @override
  Widget toGui() {
    // Use StatefulBuilder so tapping an option can call setState and rebuild
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        // treat null selection as empty list for rendering
        final List<int> sel = selection ?? <int>[];

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.asMap().entries.map((entry) {
            final int idx = entry.key;
            final String option = entry.value;
            final bool isSelected = sel.contains(idx);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    sel.remove(idx);
                  } else {
                    if (sel.length < maxSelections) {
                      sel.add(idx);
                    }
                  }
                  // write back to the nullable selection field
                  selection = List<int>.from(sel);
                });
              },
              child: Container(
                margin: const EdgeInsets.all(4.0),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  option,
                  style: TextStyle(color: isSelected ? Colors.white : Colors.black),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
  
  

}

@JsonSerializable()
class SingleChoiceNote extends Note {
  List<String> options = [];
  int? selection;

  SingleChoiceNote({
    required NoteType noteType,
    required String question,
    required this.options,
  }): super(noteType: noteType, question: question);

  // Serialization
  factory SingleChoiceNote.fromJson(Map<String, dynamic> json) => _$SingleChoiceNoteFromJson(json);
  @override Map<String, dynamic> toJson() => _$SingleChoiceNoteToJson(this);

  // generates a square button for each option (single-choice)
  @override 
  Widget toGui() {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.asMap().entries.map((entry) {
            final int idx = entry.key;
            final String option = entry.value;
            final bool isSelected = (selection != null && selection == idx);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    // deselect if tapped again
                    selection = null;
                  } else {
                    selection = idx;
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.all(4.0),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  option,
                  style: TextStyle(color: isSelected ? Colors.white : Colors.black),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
