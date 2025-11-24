import 'package:flutter/material.dart';
import '../Objects/template.dart';

/*
  On this page the user can see a summary of their session, including notes taken, time spent, etc.
  There should be an option to export the notes as a text file or PDF
  For Jackie the option to export should go straight to her email
 */

/*
  To do:
    1. display note question and answer(s)
    2. add export functionality
 */

class SessionSummary extends StatelessWidget{ 
  final Template template;

  const SessionSummary({super.key, required this.template});

@override
  Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(child: Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.name ,style: TextStyle(fontSize:24,fontWeight: FontWeight.bold)),// change title to be session.title
                SizedBox(height:12),
                Expanded(child: Center(
                  child: ListView.builder( itemCount: template.notes.length, 
                    itemBuilder: (context, index) {
                      final note = template.notes[index];
                      return ListTile(
                        title: Text(note.question),
                        subtitle: Text((note.getValueString() ?? '')),
                      );
                    },
                  ),
                )
                )
              ]
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              // Export functionality to be implemented
            },
            child: Text('Export Notes'),
          ),
        ),
      ]
    ))
  );
  }
}
