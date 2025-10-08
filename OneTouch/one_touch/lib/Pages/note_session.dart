import 'package:flutter/material.dart';

class NoteSession extends StatelessWidget{ 
  const NoteSession({super.key});

@override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Note Session')),
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

