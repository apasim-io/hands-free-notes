import 'package:flutter/material.dart';

/*
  On this page the user can see a summary of their session, including notes taken, time spent, etc.
  There should be an option to export the notes as a text file or PDF
  For Jackie the option to export should go straight to her email
 */

class SessionSummary extends StatelessWidget{ 
  const SessionSummary({super.key});

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
