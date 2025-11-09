import 'package:flutter/material.dart';
import 'package:one_touch/Objects/note.dart';
import '../Objects/template.dart';
import 'note_session.dart';
import 'template_create.dart';

class HomePage extends StatelessWidget {
  final List<Template> templates;

  HomePage({super.key, required this.templates});

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
            templates: templates,
            color: (Colors.yellow[200])!,
            listType: "session",
          ),
          SizedBox(
            height: 50,
          ),
          TemplateList(
            name: "Start session from template",
            templates: templates,
            color: (Colors.blue[300])!,
            listType: "template",
          ),
          const SizedBox(height: 12),
          // ElevatedButton(
          //   child: const Text('Go to Details Page'),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const DetailsPage()),
          //     );
          //   },
          // ),
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
  final _scrollController = ScrollController();

  TemplateList({
    super.key,
    required this.templates,
    required this.name,
    required this.color,
    required this.listType
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
                            return NoteSession(template: currTemplate);
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