import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:one_touch/Objects/note.dart';
import '../Objects/template.dart';
import 'note_session.dart';
import 'template_create.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  final List<Template> initialTemplates;
  HomePage({super.key, required this.initialTemplates});

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  // List<Template> templates = templates;

  List<Template> _templates = [];


  @override
  void initState() {
    super.initState(); // Always call super.initState() first

    // Perform one-time initialization tasks here
    _templates = widget.initialTemplates;
  }

  void saveTemplates(Template updatedTemplate, String updateType) async {
    TemplateStorage ts = TemplateStorage();
    File templatesFile = await ts.localFile(ts.templatesFName);

    // update current template state

    if (updateType == "revert") {
      // get current saved template data and revert state
      List<Template> revertedTemplates = await ts.getTemplateData(templatesFile);
      setState(() {
        _templates = revertedTemplates;
      });
    } else {
      // save updated template list to local file
      ts.saveTemplateData(_templates, templatesFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OneTouch'),
          centerTitle: true,
        ),
      body: Column(
        children: [
          TemplateList(
            name: "Recent Sessions",
            templates: _templates,
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
        ],
      )
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

class TemplateList extends StatelessWidget {
  final List<Template> templates;
  final String name;
  final Color color;
  final String listType;
  final void Function(Template, String) saveTemplatesCallback;
  final _scrollController = ScrollController();

  TemplateList({
    super.key,
    required this.templates,
    required this.name,
    required this.color,
    required this.listType,
    required this.saveTemplatesCallback
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            name,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 25
            ),
          )
        ),
        Container(
          height: 175,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          child: ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            separatorBuilder: (context, index) => SizedBox(width: 50),
            itemBuilder: (context, index) {
              Template currTemplate = templates[index];
              return SizedBox(
                width: 175,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          if (listType == "session") {
                            return NoteSession(template: currTemplate, saveTemplatesCallback: saveTemplatesCallback);
                          } else {
                            return const TemplateCreate();
                          }
                        }
                      ),
                    );
                  }, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                  child: Align(
                      child: Text(
                        currTemplate.name,
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                        ),
                      )
                    )
                  ),
              );
            },
          )
        )
      ]
    );
  }
}