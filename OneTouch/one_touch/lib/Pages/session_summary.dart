import 'package:flutter/material.dart';
import '../Objects/template.dart';

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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

  final pdf = pw.Document();

  SessionSummary({super.key, required this.template});

  bool? generatePdf() {
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(template.name, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              ...template.notes.map((note) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(note.question, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text(note.getValueString() ?? '', style: pw.TextStyle(fontSize: 16)),
                  pw.SizedBox(height: 8),
                ],
              )),
            ],
          );
        },
      ),
    );

    return true;
  }

  Future<void> exportPdf() async {
    // do a check that pdf generation was successful
    final file = File(template.name + '.pdf');
    await file.writeAsBytes(await pdf.save());
  }

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
              if (generatePdf() == true) {
                exportPdf();
                final snackBar = SnackBar(content: Text('PDF exported as ' + template.name + '.pdf'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            child: Text('Export Notes'),
          ),
        ),
      ]
    ))
  );
  }
}
