import 'package:flutter/material.dart';

/* This page will be used for creating note sessions */

class TemplateCreate extends StatefulWidget{ 
  const TemplateCreate({super.key});

  @override
  State<TemplateCreate> createState() => _TemplateCreateState();
}

class _TemplateCreateState extends State<TemplateCreate> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Template')),
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