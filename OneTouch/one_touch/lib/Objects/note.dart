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
  DateTime? interactionTime;

  Note({
    required this.noteType,
    required this.question,
    this.interactionTime
  });

  // Serialization
  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);

  void markInteraction() {
    interactionTime = DateTime.now();
  }

  Widget toGui(){ 
    return Container();
  }

  Widget toEditGui(){ 
    return Container();
  }

  String? getValueString() {
    return "No answer recorded.";
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
    DateTime? interactionTime,
  }): super(noteType: noteType, question: question, interactionTime: interactionTime);

  String? getValueString() {
    return value.toString();
  }

  // Serialization
  factory NumberScaleNote.fromJson(Map<String, dynamic> json) => _$NumberScaleNoteFromJson(json);
  @override Map<String, dynamic> toJson() => _$NumberScaleNoteToJson(this);

  @override
  Widget toGui() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: value.toDouble(),
                onChanged: (newValue) {
                  setState(() {
                    value = newValue.toInt();
                  });
                },
                min: minValue.toDouble(),
                max: maxValue.toDouble(),
                divisions: ((maxValue - minValue) / step).round(),
                label: value.round().toString(),
              ),
              const SizedBox(height: 8),
              // show min/max labels under the slider, aligned left and right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (minLabel.trim().isNotEmpty)
                    Text(minLabel, style: Theme.of(context).textTheme.bodySmall),
                  if (maxLabel.trim().isNotEmpty)
                    Text(maxLabel, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          );
        },
      ),
    );
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
    DateTime? interactionTime,
  }): super(noteType: noteType, question: question, interactionTime: interactionTime);

  String? getValueString() {
    return selection != null
      ? selection!.map((index) => options[index]).join(', ')
      : 'No selections made.';
  }

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
                  markInteraction();
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
  
  @override
  Widget toEditGui() {
    final optionController = TextEditingController();
    final questionController = TextEditingController();
    int sel = 0;

    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
      questionController.text = question;  

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                maxLines: null,
                onChanged: (value) {
                  setState(() {
                    question = value;
                  });
                },
                textAlign: TextAlign.center,
                controller: questionController,
              ),
            ),

            SizedBox(
              height: 100,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...options.asMap().entries.map((entry) {
                final int idx = entry.key;
                final String option = entry.value;
                final bool isSelected = (sel == idx);
                optionController.text = options[sel];

                return GestureDetector(
                  onTap: () {
                    options[sel] = optionController.text;
                    setState(() {
                      if (!isSelected) {
                        sel = idx;
                      } else {
                        sel = -1;
                      }
                      // write back to the nullable selection field
                      markInteraction();
                    });
                  },
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 150,
                    ),
                    margin: const EdgeInsets.all(4.0),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: isSelected ? TextField(
                      controller: optionController,
                      maxLines: null,
                      style: TextStyle(color: Colors.black),
                    )
                    : Text(option),
                  ),
                );
                }),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.black
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[300]
                  ),
                  onPressed: () {
                    setState(() {
                      sel = options.length;
                      options.add("Option ${options.length + 1}");
                    });
                  },
                  label: Text(
                    'Add Option',
                    style: TextStyle(
                      color: Colors.black
                    ),)
                ),
              ],
            )
          ]
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
    DateTime? interactionTime,
  }): super(noteType: noteType, question: question, interactionTime: interactionTime);

  String getValueString() {
    return selection != null ? options[selection!] : 'No selection made.';
  }

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
                  markInteraction();
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
