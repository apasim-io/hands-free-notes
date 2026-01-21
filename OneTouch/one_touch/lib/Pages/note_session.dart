import 'dart:developer';

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

NumberScaleNote note1 = NumberScaleNote(
  noteType: NoteType.numberScale,
  question: "On a scale of 0-10, how are you feeling today?",
  minValue: 0,
  maxValue: 10,
  step: 1,
  minLabel: "Very Bad",
  maxLabel: "Excellent",
);

SingleChoiceNote note2 = SingleChoiceNote(
  noteType: NoteType.singleChoice,
  question: "What is your current mood?",
  options: ["Happy", "Sad", "Angry", "Anxious", "Excited"],
);

MultipleChoiceNote note3 = MultipleChoiceNote(
  noteType: NoteType.multipleChoice,
  question: "Which of the following symptoms are you experiencing?",
  options: ["Headache", "Nausea", "Fatigue", "Dizziness", "Cough"],
  maxSelections: 3,
);

List<Note> notesList = [note1, note2, note3];

class NoteSession extends StatefulWidget {
  final Template template;

  final void Function(Template, String) saveTemplatesCallback;
  const NoteSession({
    super.key,
    required this.template,
    required this.saveTemplatesCallback,
  });

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
      appBar: AppBar(
        leadingWidth: 125,
        leading: Container(
          margin: EdgeInsets.only(left: 20, top: 5, bottom: 5),
          child: FloatingActionButton.extended(
            elevation: 0,
            heroTag: 'exit',
            onPressed: () {
              // cancel changes and reset templates
              widget.saveTemplatesCallback(widget.template, "revert");
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.keyboard_return,
              color: Colors.black
            ),
            label: const Text(
              'Exit',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            backgroundColor: Color.fromARGB(189, 0, 153, 255),
          ),
        ),
        centerTitle: true,
        title: RichText(
        text: TextSpan(
            text: widget.template.name,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          )
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        actions: [
          FloatingActionButton.extended(
            elevation: 0,
            heroTag: 'save',
            onPressed: () {
              // cancel changes and reset templates
              widget.saveTemplatesCallback(widget.template, "save");
            },
            icon: const Icon(
              Icons.save,
              color: Colors.black
            ),
            label: const Text(
              'Save',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            backgroundColor: Color.fromARGB(189, 0, 255, 0),
          ),
          SizedBox(
            width: 20,
          ),
          FloatingActionButton.extended(
            elevation: 0,
            heroTag: 'delete',
            onPressed: () {
              // cancel changes and reset templates
              widget.saveTemplatesCallback(widget.template, "delete");
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.cancel,
              color: Colors.black
            ),
            label: const Text(
              'Delete',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            backgroundColor: Color.fromARGB(190, 255, 0, 0),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10),
        child: Row(
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
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: SizedBox(
                      height: 120,
                      width: 160,
                      child: FloatingActionButton.extended(
                        elevation: 0,
                        heroTag: 'continue',                     
                        onPressed: () {
                          setState(() {
                            if (notes.isEmpty) return;

                            // if nothing selected yet, start with the first note
                            if (selected == null) {
                              selected = 0;
                              return;
                            }

                            // If at last note, save and navigate to the summary page
                            if (selected == notes.length - 1) {
                              widget.saveTemplatesCallback(widget.template, "save");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SessionSummary(
                                    template: widget.template,
                                  ),
                                ),
                              );
                              return;
                            }

                            // Otherwise, go to next note
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
      )
    );
  }
}

