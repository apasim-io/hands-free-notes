import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';

// Pages
import 'Pages/note_session.dart';
import 'Pages/session_summary.dart';
import 'Pages/template_create.dart';

//data objects
import 'Objects/template.dart';
import 'Objects/note.dart'; // don't use yet, make sure to delete if we don't need

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final jsonString = await rootBundle.loadString('assets/data/example_a.json');
  final templateMap = jsonDecode(jsonString) as Map<String, dynamic>;
  Template currentTemp = Template.fromJson(templateMap);

  // for testing files and json conversion:
  // SessionStorage s = SessionStorage();
  // final File sessionsFile = await s.localFile();
  // s.saveSessionData([currentSession], sessionsFile);
  // final res = await s.readSessionData(sessionsFile);

  /*
    TO DO:
    1. figure out how to store and load ALL session 
    2. make all of the individual pages prettier
    3. make sure all of different note types load correctly WITH different values
    4. build out other pages: session summary ....
    5. figure out local storage for sessions, we should be able to save user progress so
      they can come back later
  
   */
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(template: currentTemp),
    )
  );
}

//

class HomePage extends StatelessWidget {
  final Template template;

  const HomePage({super.key, required this.template});

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
                    builder: (context) => NoteSession(template: template),
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
