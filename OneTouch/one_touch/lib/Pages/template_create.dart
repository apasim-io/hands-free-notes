import 'package:flutter/material.dart';

/* This page will be used for creating note sessions */

class TemplateCreate extends StatelessWidget{ 
  const TemplateCreate({super.key});

@override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Template Page')),
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
