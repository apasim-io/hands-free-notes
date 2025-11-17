import 'package:flutter/material.dart';
import 'package:one_touch/Objects/note.dart';
import 'package:one_touch/Pages/home_page.dart';
import 'package:one_touch/Pages/session_summary.dart';
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

class NoteSession extends StatefulWidget {
  final Template template;
  const NoteSession({super.key, required this.template});

  @override
  State<NoteSession> createState() => _NoteSessionState();
}

class _NoteSessionState extends State<NoteSession> {
  int? selected; //this is to chagne the widget showing on the right

  @override
  Widget build(BuildContext context) {
    final notes = widget.template.notes;

    //shortcut to check for last not on build
    final bool isLastNote = selected != null && selected == notes.length - 1;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //left column: one item per note in the template. 
          SizedBox(
            width: 200, // tweak as you like
            child: ListView.separated( //seperated until they become there own squares
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];//use this later to
                final isSelected = selected == index;
                return ListTile( //so it can be clicked on
                  dense: true,
                  title: Text(note.question),//example: could be changed to title
                  selected: isSelected, //next 3 lines for coloring
                  selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
                  selectedColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  onTap: () => setState(() => selected = index),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
            ),
          ),
          //divider should just be a line to seperate them
          const VerticalDivider(width: 1),
          //Right column expands to fill space
          Expanded(
            child: Stack(
              children: [
                //stack for layering the buttons
                Positioned.fill(
                  child: (selected == null)
                      ? const Center(child: Text('Select a note'))
                      : Center(
                          child: KeyedSubtree(
                            key: ValueKey(selected),
                            child: notes[selected!].toGui(),
                          ),
                        ),
                ),

                //bottom-right next trial botton
                Positioned(
                  right: 16,
                  top: 16,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel Session'),
                    backgroundColor: Color.fromARGB(190, 255, 0, 0),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: SizedBox(
                    height: 120,
                    width: 160,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        setState(() {

                          if (isLastNote) {
                            //if we are already on the last note: finish the session
                            // TO Do - Call the next method~!
                            return;
                          }

                          if (notes.isEmpty) return;

                          //if nothing selected yet, start with the first note
                          if (selected == null) {
                            selected = 0;
                            return;
                          }

                          //If not at last note, go to next one
                          if (selected! < notes.length - 1) {
                            selected = selected! + 1;
                          }
                        });
                      },
                      icon: Icon(Icons.arrow_forward),
                      label: Text(isLastNote ? 'Finish' : 'Next'),
                    ),
                  )
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

