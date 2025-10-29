import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// Pages
import 'Pages/note_session.dart';
import 'Pages/session_summary.dart';
import 'Pages/template.dart';

//data objects
import 'Objects/session.dart';
import 'Objects/note.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final jsonString = await rootBundle.loadString('Assets/Data/example_a.json');
  final sessionMap = jsonDecode(jsonString) as Map<String, dynamic>;
  Session currentSession = Session.fromJson(sessionMap);
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
      home: HomePage(session: currentSession),
    ),
  );
}

//

class HomePage extends StatelessWidget {
  final Session session;

  const HomePage({super.key, required this.session});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                      'Session 1',
                      textAlign: TextAlign.center,
                      )
                    )
                  ),
                ),
              ]
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteSession(session: session),
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
