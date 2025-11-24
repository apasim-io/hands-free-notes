import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:developer';

// Pages
import 'Pages/note_session.dart';
import 'Pages/session_summary.dart';
import 'Pages/template_create.dart';
import 'Pages/home_page.dart';

//data objects
import 'Objects/template.dart';
import 'Objects/note.dart'; // don't use yet, make sure to delete if we don't need

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  TemplateStorage ts = TemplateStorage();
  // retrieve and save sample template data to device
  List<Template> sampleTemplates = await ts.getSampleTemplates('assets/data/example_b.json');
  ts.saveTemplateData(sampleTemplates, await ts.localFile(ts.templatesFName));

  // get saved templates from target device
  List<Template> templates = await ts.getTemplateData(await ts.localFile(ts.templatesFName));
  inspect(templates);

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
        home: HomePage(initialTemplates: templates), 
      )
  );
}
