
import 'package:flutter/material.dart';
import 'session_create.dart';
import '../Objects/template.dart';
import 'note_session.dart';
import 'template_create.dart';
import 'dart:io';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  final List<Template> initialTemplates;
  final List<Template> initialSessions;

  const HomePage({super.key, required this.initialTemplates, required this.initialSessions});

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
      int deletedIdx = _sessions.indexWhere((session) => session.id == updatedTemplate[0].id);
      if (deletedIdx < 0) {
        deletedIdx = _templates.indexWhere((template) => template.id == updatedTemplate[0].id);
        updatedTemplates.removeAt(deletedIdx);
      } else {
      updatedSessions.removeAt(deletedIdx);
      }
    } else if (updateType == "addSession") {
      updatedSessions.add(updatedTemplate[0]);
    } else if (updateType == "addTemplate") {
      updatedTemplates.add(updatedTemplate[0]);
    }
    else if (updateType == "save") {
      // set updates to current state
      updatedTemplates = _templates;
      updatedSessions = _sessions;
    } else if (updateType == "massDelete") {
      for (int i = 0; i < updatedTemplate.length; i++) {
        int deletedIdx = updatedSessions.indexWhere((session) => session.id == updatedTemplate[i].id);
        if (deletedIdx < 0) {
          deletedIdx = updatedTemplates.indexWhere((template) => template.id == updatedTemplate[i].id);
          print("deleted template: ${deletedIdx}");
          updatedTemplates.removeAt(deletedIdx);
        } else {
        print("deleted session: ${deletedIdx}");
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
      title: const Text('OneTouch'),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsPage(),
              ),
            );
          },
        ),
      ],
    ),
      body: Column(
        children: [
          TemplateList(
            name: "Recent Sessions",
            templates: _sessions,
            color: (Colors.yellow[200])!,
            listType: "session",
            saveTemplatesCallback: saveTemplates
          ),
          SizedBox(
            height: 50,
          ),
          TemplateList(
            name: "Start session from template",
            templates: _templates,
            color: (Colors.blue[300])!,
            listType: "template",
            saveTemplatesCallback: saveTemplates
          ),
          ElevatedButton(
            child: const Text('Create new Template'),
            onPressed: () {
              Template defaultTemplate = Template(notes: [], name: "Template ${_templates.length + 1}");
              saveTemplates([defaultTemplate], "addTemplate");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return TemplateCreate(
                      template: defaultTemplate,
                      saveTemplatesCallback: saveTemplates);
                  }
                ),
              );
            },
          ),
        ],
        ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details Page')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go Back'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class TemplateList extends StatefulWidget {
  final List<Template> templates;
  final String name;
  final Color color;
  final String listType;
  final void Function(List<Template>, String) saveTemplatesCallback;

  const TemplateList({
    super.key,
    required this.templates,
    required this.name,
    required this.color,
    required this.listType,
    required this.saveTemplatesCallback
  });

  @override
  State<TemplateList> createState() => _TemplateListState();
}

class _TemplateListState extends State<TemplateList> {
  final _scrollController = ScrollController();
  List<String> selectedIds = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                onPressed:() {
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
                  });
                },
                child: Text(
                  "Delete Selected",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 15
                  ),
                )
              )
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                widget.name,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 25
                ),
              )
            )
          ],
        ),
        Container(
          height: 175,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          child: ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            scrollDirection: Axis.horizontal,
            itemCount: widget.templates.length,
            separatorBuilder: (context, index) => SizedBox(width: 50),
            itemBuilder: (context, index) {
              Template currTemplate = widget.templates[index];
              return SizedBox(
                width: 175,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          if (widget.listType == "session") {
                            return NoteSession(template: currTemplate, saveTemplatesCallback: widget.saveTemplatesCallback);
                          } else {
                            // listType == "template"
                            return SessionCreate(template: currTemplate, saveTemplatesCallback: widget.saveTemplatesCallback);
                          }
                        }
                      ),
                    );
                  }, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.all(0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Checkbox(
                            value: selectedIds.contains(currTemplate.id), // Assign the state variable
                            onChanged: (bool? newValue) {
                              setState(() {
                                if (newValue == true) {
                                  selectedIds.add(currTemplate.id); // Update the state
                                } else {
                                  selectedIds.remove(currTemplate.id);
                                }
                              });
                            },
                            activeColor: Colors.blue, // Customize the color when checked
                          ),
                          )
                        ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          currTemplate.name,
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                            ),
                          )
                      ),
                    ],
                  )
                )
              );
            },
          )
        ),
      ]
    );
  }
}