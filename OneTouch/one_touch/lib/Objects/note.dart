import 'package:json_annotation/json_annotation.dart';

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
}

@JsonSerializable()
class NumberScaleNote extends Note {
  int minValue = 0;
  int maxValue = 10;
  int step = 1;
  String minLabel = "Low";
  String maxLabel = "High";
  int? selection;

  NumberScaleNote({
    required super.noteType,
    required super.question,
    required this.minValue,
    required this.maxValue,
    required this.step,
    required this.minLabel,
    required this.maxLabel,
  });

  // Serialization
  factory NumberScaleNote.fromJson(Map<String, dynamic> json) => _$NumberScaleNoteFromJson(json);
  Map<String, dynamic> toJson() => _$NumberScaleNoteToJson(this);

  // TO DO : add toGui function

}

/*
  MultipleChoiceNotes should have a different physical shape than SingleChoiceNotes
  to make it easier for users to distinguish between the two types of notes
 */
@JsonSerializable()
class MultipleChoiceNote extends Note {
  List<String> options = [];
  int maxSelections = 3;
  List<int> selection = [];

  MultipleChoiceNote({
    required super.noteType,
    required super.question,
    required this.options,
    required this.maxSelections,
  });

  // Serialization
  factory MultipleChoiceNote.fromJson(Map<String, dynamic> json) => _$MultipleChoiceNoteFromJson(json);
  Map<String, dynamic> toJson() => _$MultipleChoiceNoteToJson(this);

  // TO DO : add toGui function

}

@JsonSerializable()
class SingleChoiceNote extends Note {
  List<String> options = [];
  int? selection;

  SingleChoiceNote({
    required super.noteType,
    required super.question,
    required this.options,
  });

  // Serialization
  factory SingleChoiceNote.fromJson(Map<String, dynamic> json) => _$SingleChoiceNoteFromJson(json);
  Map<String, dynamic> toJson() => _$SingleChoiceNoteToJson(this);

  // TO DO : add toGui function

}
