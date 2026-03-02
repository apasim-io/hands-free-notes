import 'package:flutter/material.dart';
import 'session_create.dart';
import '../Objects/template.dart';
import 'note_session.dart';
import 'template_create.dart';
import 'dart:io';
import 'dart:math' as math;
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  final List<Template> initialTemplates;
  final List<Template> initialSessions;

  const HomePage({
    super.key,
    required this.initialTemplates,
    required this.initialSessions,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List<Template> templates = templates;

  List<Template> _templates = [];
  List<Template> _sessions = [];

  @override
  void initState() {
    super.initState(); // Always call super.initState() first

    // Perform one-time initialization tasks here
    _sessions = widget.initialSessions;
    _templates = widget.initialTemplates;
  }

  void saveTemplates(List<Template> updatedTemplate, String updateType) async {
    TemplateStorage ts = TemplateStorage();
    File templatesFile = await ts.localFile(ts.templatesFName);
    File sessionsFile = await ts.localFile(ts.sessionsFName);

    // update current template state
    List<Template> updatedTemplates = await ts.getTemplateData(templatesFile);
    List<Template> updatedSessions = await ts.getTemplateData(sessionsFile);

    if (updateType == "revert") {
      // do nothing (updated lists are already set to get previous save data)
    } else if (updateType == "delete") {
      // check both sessions and templates
      int deletedIdx = _sessions.indexWhere(
        (session) => session.id == updatedTemplate[0].id,
      );
      if (deletedIdx < 0) {
        deletedIdx = _templates.indexWhere(
          (template) => template.id == updatedTemplate[0].id,
        );
        updatedTemplates.removeAt(deletedIdx);
      } else {
        updatedSessions.removeAt(deletedIdx);
      }
    } else if (updateType == "addSession") {
      updatedSessions.add(updatedTemplate[0]);
    } else if (updateType == "addTemplate") {
      updatedTemplates.add(updatedTemplate[0]);
    } else if (updateType == "save") {
      // set updates to current state
      updatedTemplates = _templates;
      updatedSessions = _sessions;
    } else if (updateType == "massDelete") {
      for (int i = 0; i < updatedTemplate.length; i++) {
        int deletedIdx = updatedSessions.indexWhere(
          (session) => session.id == updatedTemplate[i].id,
        );
        if (deletedIdx < 0) {
          deletedIdx = updatedTemplates.indexWhere(
            (template) => template.id == updatedTemplate[i].id,
          );
          //print("deleted template: ${deletedIdx}"); /*Commented out for production */
          updatedTemplates.removeAt(deletedIdx);
        } else {
          //print("deleted session: ${deletedIdx}"); /*Commented out for production */
          updatedSessions.removeAt(deletedIdx);
        }
      }
    }

    // save to files
    ts.saveTemplateData(updatedSessions, sessionsFile);
    ts.saveTemplateData(updatedTemplates, templatesFile);
    // save states
    setState(() {
      _sessions = updatedSessions;
      _templates = updatedTemplates;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OneTouch',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 13, 27, 42),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Column(
            children: [
              TemplateList(
                name: "Recent Sessions",
                templates: _sessions,
                color: (Color.fromARGB(255, 84, 122, 165))!,
                textColor: Colors.white,
                listType: "session",
                saveTemplatesCallback: saveTemplates,
              ),
              const SizedBox(height: 50),
              TemplateList(
                name: "Start session from template",
                templates: _templates,
                color: (Color.fromARGB(255, 224, 225, 221))!,
                textColor: Color.fromARGB(255, 13, 27, 42),
                listType: "template",
                saveTemplatesCallback: saveTemplates,
              ),
              ElevatedButton(
                child: const Text('Create new Template'),
                onPressed: () {
                  Template defaultTemplate = Template(
                    notes: [],
                    name: "Template ${_templates.length + 1}",
                  );
                  saveTemplates([defaultTemplate], "addTemplate");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return TemplateCreate(
                          template: defaultTemplate,
                          saveTemplatesCallback: saveTemplates,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TemplateList extends StatefulWidget {
  final List<Template> templates;
  final String name;
  final Color color;
  final Color textColor;
  final String listType;
  final void Function(List<Template>, String) saveTemplatesCallback;

  const TemplateList({
    super.key,
    required this.templates,
    required this.name,
    required this.color,
    required this.textColor,
    required this.listType,
    required this.saveTemplatesCallback,
  });

  @override
  State<TemplateList> createState() => _TemplateListState();
}

class _TemplateListState extends State<TemplateList> {
  final _scrollController = ScrollController();
  List<String> selectedIds = [];
  bool _selectionMode = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double headerMargin = screenWidth > 600 ? 30.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: headerMargin, bottom: 8.0),
          child: Text(
            widget.name,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Color.fromARGB(255, 13, 27, 42),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: headerMargin, bottom: 8.0),
          child: ElevatedButton(
            onPressed: () {
              // First click: enter selection mode and show checkboxes
              if (!_selectionMode) {
                setState(() {
                  _selectionMode = true;
                  selectedIds = [];
                });
                return;
              }

              // Second click: perform deletion
              List<Template> toDelete = [];
              for (int i = 0; i < widget.templates.length; i++) {
                Template curr = widget.templates[i];
                if (selectedIds.contains(curr.id)) {
                  toDelete.add(curr);
                }
              }
              widget.saveTemplatesCallback(toDelete, "massDelete");
              setState(() {
                selectedIds = [];
                _selectionMode = false;
              });
            },
            child: Text(
              _selectionMode ? "Delete Selected" : "Select Items",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = MediaQuery.of(context).size.width;
            final double horizMargin = screenWidth > 600 ? 30 : 16;
            final double listHeight = math.min(
              220,
              math.max(140, screenWidth * 0.32),
            );
            final double itemWidth = math.min(
              220,
              math.max(140, screenWidth * 0.36),
            );

            return Container(
              height: listHeight,
              margin: EdgeInsets.symmetric(horizontal: horizMargin),
              child: ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                scrollDirection: Axis.horizontal,
                itemCount: widget.templates.length,
                separatorBuilder: (context, index) =>
                    SizedBox(width: itemWidth * 0.2),
                itemBuilder: (context, index) {
                  Template currTemplate = widget.templates[index];
                  return SizedBox(
                    width: itemWidth,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              if (widget.listType == "session") {
                                return NoteSession(
                                  template: currTemplate,
                                  saveTemplatesCallback:
                                      widget.saveTemplatesCallback,
                                );
                              } else {
                                // listType == "template"
                                return SessionCreate(
                                  template: currTemplate,
                                  saveTemplatesCallback:
                                      widget.saveTemplatesCallback,
                                );
                              }
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(0),
                        backgroundColor: widget.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsetsGeometry.directional(bottom: 5),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: _selectionMode
                                ? SizedBox(
                                  height: 75,
                                  child: Container(
                                    margin: EdgeInsetsGeometry.directional(bottom: 25),
                                    child: Checkbox(
                                    value: selectedIds.contains(
                                      currTemplate.id,
                                    ), // Assign the state variable
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        if (newValue == true) {
                                          selectedIds.add(
                                            currTemplate.id,
                                          ); // Update the state
                                        } else {
                                          selectedIds.remove(currTemplate.id);
                                        }
                                      });
                                    },
                                    shape: CircleBorder(),
                                    checkColor:
                                        Color.fromARGB(255, 13, 27, 42),
                                    activeColor: Color.fromARGB(
                                      255,
                                      244,
                                      208,
                                      111,
                                    ), // Customize the color when checked
                                  )
                                  )
                                )
                                : const SizedBox(
                                  height: 75,
                                ),
                          ),
                        ),
                          // alignment: Alignment.center,
                          Padding(
                            padding: EdgeInsetsGeometry.symmetric(
                              horizontal: 15,
                            ),
                              child: Center(
                                child: Text(
                                currTemplate.name,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: widget.textColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
