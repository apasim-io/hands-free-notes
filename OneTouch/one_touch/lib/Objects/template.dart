import 'note.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class TemplateStorage {
  Future<String> localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    // print("The path is $directory");
    return directory.path;
  }

  Future<File> localFile() async {
    final path = await localPath();
    return File('$path/templates.json');
  }

  void saveTemplateData(List templates, File file) {
    final jsonList = jsonEncode(templates);
    file.writeAsString(jsonList);

    // print(jsonList);
    // File testFile = File('/storage/emulated/0/Download/test.txt');
    // testFile.writeAsString(jsonList);
  }

  Future<String> readTemplateData(File file) async {
    final contents = await file.readAsString();
    return contents;
  }

}


// a template containing multiple pages of notes
class Template {
  String name = "New Template";
  final List<Note> notes;

  Template({List<Note>? notes, String? name}) : notes = notes ?? []{
    if (name != null) this.name = name;
  }

  void setName(String newName) {
    name = newName;
  }

  // Add a page to the template.
  void add(Note note) => notes.add(note);

  // Remove a page from the session. Returns true if removed.
  bool remove(Note note) => notes.remove(note);

  // Return the page at [index], or null if index is out of range.
  Note? getAt(int index) => (index >= 0 && index < notes.length) ? notes[index] : null;

  // Remove all pages.
  void clear() => notes.clear();

  // Number of pages in the session.
  int get length => notes.length;

  @override
  String toString() => 'Session(notes: $notes)';

  Template.fromJson(Map<String, dynamic> json):
    name = json['template_name'] ?? 'New Template',
    notes = (json['notes'] as List<dynamic>?)
            ?.map((e) => Note.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

  Map<String, dynamic> toJson() => {
    'template_name': name,
    'notes': notes.map((note) => note.toJson()).toList()
  };

}

