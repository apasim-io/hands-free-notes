import 'package:flutter/material.dart';
import 'dart:developer';

// Pages
import 'Pages/home_page.dart';

//data objects
import 'Objects/template.dart';
// don't use yet, make sure to delete if we don't need

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // retrieve and save sample template data to device
  TemplateStorage ts = TemplateStorage();
  List<Template> sampleTemplates = await ts.getSampleTemplates('assets/data/example_b.json');
  ts.saveTemplateData(sampleTemplates, await ts.localFile(ts.templatesFName));
  ts.saveTemplateData(sampleTemplates, await ts.localFile(ts.sessionsFName));

  // get saved templates from target device
  // generate ids for new sample objects
  List<Template> templates = await ts.getTemplateData(await ts.localFile(ts.templatesFName));
  for (final (index, template) in templates.indexed) {
    templates[index].id = template.idGenerator();
    templates[index].name = 'Template ${index + 1}';
  }
  List<Template> sessions = await ts.getTemplateData(await ts.localFile(ts.sessionsFName));
  for (var session in sessions) {
    session.id = session.idGenerator();
  }
  ts.saveTemplateData(sessions, await ts.localFile(ts.sessionsFName));
  ts.saveTemplateData(templates, await ts.localFile(ts.templatesFName));

  inspect(templates);
  inspect(sessions);

  /*
    TO DO:
    1. figure out how to store and load ALL session 
    2. make all of the individual pages prettier
    3. make sure all of different note types load correctly WITH different values
    4. build out other pages: session summary ....
    5. figure out local storage for sessions, we should be able to save user progress so
      they can come back later
  
   */

  ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(200, 11, 53, 99), // Background color
      foregroundColor: Colors.white, // Text and icon color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Button padding
      textStyle: TextStyle(fontSize: 18), // Text style
    ),
  );



  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
        // ... other theme properties
          elevatedButtonTheme: elevatedButtonTheme,
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Color.fromARGB(255, 11, 53, 99),
            selectionHandleColor: Color.fromARGB(255, 11, 53, 99),
          ),
          inputDecorationTheme: InputDecorationTheme(
            // Default border style
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey),
            ),
            // Focused border style
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color.fromARGB(255, 102, 153, 204), width: 2),
            ),      
            // Color for hint text
            hintStyle: TextStyle(color: Colors.grey),
            // Color for label text when not focused
            labelStyle: TextStyle(color: Colors.black54),
            focusColor: Color.fromARGB(255, 102, 153, 204),
            // Color for floating label when focused
            floatingLabelStyle: TextStyle(color: Color.fromARGB(255, 11, 53, 99)),
          ),
          fontFamily: "Noto-Sans",
        ),
        home: HomePage(
          initialTemplates: templates,
          initialSessions: sessions
        ), 
      )
  );
}
