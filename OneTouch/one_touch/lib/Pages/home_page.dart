import 'package:flutter/material.dart';
import 'package:one_touch/Objects/note.dart';
import '../Objects/template.dart';
import 'note_session.dart';

class HomePage extends StatelessWidget {
  final List<Template> templates;

  HomePage({super.key, required this.templates});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
        ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Recent Sessions'),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {}, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[100],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),
                      textStyle: TextStyle(
                        color: Colors.black,
                      )
                    ),
                    child: Container(
                      height: 150,
                      width: 150,
                      child: Align(
                        child: Text(
                        'session 1',
                        textAlign: TextAlign.center,
                        )
                      )
                    ),
                  ),
                ]
              ), 
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteSession(template: templates[0]),
                  ),
                );
              },
              child: const Text('Go to note session'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              child: const Text('Go to Details Page'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DetailsPage()),
                );
              },
            ),
          ],
        ),
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