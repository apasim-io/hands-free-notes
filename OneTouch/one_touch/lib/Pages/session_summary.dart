import 'package:flutter/material.dart';
import '../Objects/template.dart';

import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

/*
  On this page the user can see a summary of their session, including notes taken, time spent, etc.
  There should be an option to export the notes as a text file or PDF
  For Jackie the option to export should go straight to her email
 */

/*
  To do:
    1. export to email
    2. make pdf prettier
      2a. make the review of questions a preview of the pdf, so that what the user sees in the app is the final product
 */

class SessionSummary extends StatelessWidget {
  final Template template;
  final pw.Document pdf = pw.Document();
  String pdfPath = '';
  bool pdfExported = false;

  SessionSummary({super.key, required this.template});

  // Create and return a new PDF document containing the session summary.
  pw.Document generatePdf() {
    final doc = pw.Document();

    // this doc currently only makes one page
    // how to dynamically size the pdf so that it is organized, legible, and compact?
    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                template.name,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              ...template.notes.map(
                (note) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      note.question,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      note.getValueString() ?? '',
                      style: pw.TextStyle(fontSize: 16),
                    ),
                    pw.SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc;
  }

  Future<bool> exportPdf() async {
    try {
      // Generate a fresh document for each export to avoid duplicate pages
      final doc = generatePdf();

      if (Platform.isAndroid) {
        // Try to get the shared Downloads directory on Android
        final dirs = await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        );
        if (dirs != null && dirs.isNotEmpty) {
          pdfPath = '${dirs.first.path}/${template.name}.pdf';
        } else {
          final directory = await getApplicationDocumentsDirectory();
          pdfPath = '${directory.path}/${template.name}.pdf';
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        pdfPath = '${directory.path}/${template.name}.pdf';
      }

      final file = File(pdfPath);
      final bytes = await doc.save();
      await file.writeAsBytes(bytes);

      // Print the saved file path to the console for debugging
      print('PDF exported to: $pdfPath');

      pdfExported = true;
      return true;
    } catch (e) {
      print('PDF export failed: $e');
      return false;
    }
  }

  Future<bool> emailPdf() async {
    try {
      // attempt to email pdf
      if (!pdfExported) {
        print('PDF must be exported first!');
        return false;
      }

      final Email email = Email(
        subject: '${template.name}.pdf',
        recipients: [
          'pasimia@wwu.edu',
        ], // this should be a user email that is saved
        attachmentPaths: [pdfPath],
      );

      await FlutterEmailSender.send(email);

      return true;
    } catch (e) {
      print('PDF email failed: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ), // change title to be session.title
                    SizedBox(height: 12),
                    Expanded(
                      child: Center(
                        child: ListView.builder(
                          itemCount: template.notes.length,
                          itemBuilder: (context, index) {
                            final note = template.notes[index];
                            return ListTile(
                              title: Text(note.question),
                              subtitle: Text((note.getValueString() ?? '')),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column( // Changed back to Column for vertical layout to ensure buttons are visible
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Export PDF (exportPdf generates a fresh document internally)
                        if (await exportPdf()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'PDF exported as ${template.name}.pdf',
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to export pdf: (insert error handling here)',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to export pdf: $e')),
                        );
                      }
                    },
                    child: Text('Export Notes'),
                  ),
                  SizedBox(height: 16), // Spacing between buttons
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await emailPdf();
                      } catch (e) {
                        // print an error msg
                      }
                    },
                    child: Text('Email Notes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
