import 'package:flutter/material.dart';
import '../Objects/template.dart';
import '../Objects/note.dart';
import 'dart:math';

/* This page will be used for creating note sessions */

class TemplateCreate extends StatefulWidget {
  final Template template;
  final void Function(List<Template>, String) saveTemplatesCallback;
  const TemplateCreate({
    super.key,
    required this.template,
    required this.saveTemplatesCallback,
  });

  @override
  State<TemplateCreate> createState() => _TemplateCreateState();
}

class _TemplateCreateState extends State<TemplateCreate> {
  int? selected; //this is to chagne the widget showing on the right
  final textController = TextEditingController();
  Template? _template;
  NoteType _selectedNoteType = NoteType.multipleChoice;

  @override
  // clean up controller when widget is disposed
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    textController.text = widget.template.name;
    _template = widget.template;
    _selectedNoteType = NoteType.multipleChoice;
  }

  Note createDefaultNote(NoteType type) {
    switch (type) {
      case NoteType.nullType:
        return Note(noteType: type, question: "new question");
      case NoteType.numberScale:
        return NumberScaleNote(
          noteType: type,
          question: "new question",
          minValue: 1,
          maxValue: 10,
          step: 1,
          minLabel: "min",
          maxLabel: "max",
        );
      case NoteType.text:
        return Note(noteType: type, question: "new question");
      case NoteType.multipleChoice:
        return MultipleChoiceNote(
          noteType: type,
          question: "new question",
          options: ["option 1", "option 2"],
          maxSelections: 2,
        );
      case NoteType.singleChoice:
        return SingleChoiceNote(
          noteType: type,
          question: "new question",
          options: ["option 1", "option 2"],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    //shortcut to check for last not on build
    final bool isLastNote =
        selected != null && selected == _template!.notes.length - 1;

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
              widget.saveTemplatesCallback([widget.template], "revert");
              Navigator.pop(context);
            },
            icon: const Icon(Icons.keyboard_return, color: Colors.white),
            label: const Text(
              'Exit',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            backgroundColor: Color.fromARGB(200, 11, 53, 99),
          ),
        ),
        centerTitle: true,
        title: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: TextField(
            textAlign: TextAlign.center,
            controller: textController,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        actions: [
          FloatingActionButton.extended(
            elevation: 0,
            heroTag: 'save',
            onPressed: () {
              // save template creation progress
              setState(() {
                _template?.name = textController.text;
              });
              widget.saveTemplatesCallback([_template!], "save");
            },
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              'Save',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            backgroundColor: Color.fromARGB(255, 102, 153, 204),
          ),
          SizedBox(width: 20),
          FloatingActionButton.extended(
            elevation: 0,
            heroTag: 'delete',
            onPressed: () {
              // cancel changes and reset templates
              widget.saveTemplatesCallback([widget.template], "delete");
              Navigator.pop(context);
            },
            icon: const Icon(Icons.cancel, color: Colors.white),
            label: const Text(
              'Delete',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            backgroundColor: Color.fromARGB(200, 11, 53, 99),
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
              child: ListView.separated(
                //seperated until they become there own squares
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _template!.notes.length + 1,
                itemBuilder: (context, index) {
                  if (index == _template!.notes.length) {
                    return Container(
                      margin: EdgeInsets.only(top: 20),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text("New note"),
                        onPressed: () {
                          // set state with new note
                          setState(() {
                            // Template newTemplate = _template!;
                            _template!.notes.add(
                              createDefaultNote(_selectedNoteType),
                            );
                            selected = _template!.notes.length - 1;
                            // _template = new
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ),
                    );
                  }
                  final note = _template!.notes[index]; //use this later to
                  final isSelected = selected == index;
                  return Row(
                    children: [
                      Flexible(
                        child: ListTile(
                          //so it can be clicked on
                          dense: true,
                          title: Text(
                            note.question,
                          ), //example: could be changed to title
                          selected: isSelected, //next 3 lines for coloring
                          selectedTileColor: Color.fromARGB(255, 102, 153, 204),
                          selectedColor: Colors.white,
                          onTap: () => setState(() {
                            selected = index;
                            _selectedNoteType =
                                _template!.notes[selected!].noteType;
                          }),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete',
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            _template!.notes.removeAt(index);
                            if (selected == index) {
                              selected = max(index - 1, 0);
                            }
                          });
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Color.fromARGB(200, 11, 53, 99),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ],
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
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: DropdownButton<NoteType>(
                      hint: Text("Note Type"),
                      value: _selectedNoteType,

                      items: noteTypeNames.keys.map((String noteName) {
                        return DropdownMenuItem<NoteType>(
                          value: noteTypeNames[noteName],
                          child: Text(noteName),
                        );
                      }).toList(),
                      onChanged: (newNoteType) {
                        setState(() {
                          _selectedNoteType = newNoteType!;
                          if (selected != null) {
                            _template!.notes[selected!] = createDefaultNote(
                              newNoteType,
                            );
                          }
                        });
                      },
                    ),
                  ),

                  //stack for layering the buttons
                  Positioned.fill(
                    child: ((selected == null) || (_template!.notes.isEmpty))
                        ? Center(
                            child: ElevatedButton.icon(
                              label: const Text("New note"),
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: () {
                                // set state with new note
                                setState(() {
                                  // Template newTemplate = _template!;
                                  _template!.notes.add(
                                    createDefaultNote(_selectedNoteType),
                                  );
                                  selected = _template!.notes.length - 1;
                                  // _template = new
                                });
                              },
                            ),
                          )
                        : Center(
                            child: KeyedSubtree(
                              key: ValueKey(selected),
                              child: _template!.notes[selected!].toEditGui(),
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
                            if (isLastNote) {
                              //if we are already on the last note: finish the session
                              // TO Do - Call the next method~!
                              // save note progress
                              widget.saveTemplatesCallback([
                                widget.template,
                              ], "save");
                              Navigator.pop(context);
                              return;
                            }

                            if (_template!.notes.isEmpty) return;

                            //if nothing selected yet, start with the first note
                            if (selected == null) {
                              selected = 0;
                              return;
                            }

                            //If not at last note, go to next one
                            if (selected! < _template!.notes.length - 1) {
                              selected = selected! + 1;
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        label: Text(
                          isLastNote ? 'Finish' : 'Next',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Color.fromARGB(200, 11, 53, 99),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
