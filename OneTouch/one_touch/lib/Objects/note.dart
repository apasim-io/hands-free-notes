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