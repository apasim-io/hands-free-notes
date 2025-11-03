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
    appBar: AppBar(title: const Text('Session Summary')),
    body: Center(
      child: ElevatedButton(
        child: const Text('Back to Home Page'),
        onPressed: (){
          Navigator.pop(context);
        },
      )
    )
  );
  }
}
