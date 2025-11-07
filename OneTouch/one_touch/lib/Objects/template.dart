import 'package:json_annotation/json_annotation.dart';
import 'note.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

part 'template.g.dart';

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
@JsonSerializable()
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
  String toString() => 'Template(notes: $notes)';

  factory Template.fromJson(Map<String, dynamic> json) => _$TemplateFromJson(json);
  Map<String, dynamic> toJson() => _$TemplateToJson(this);
}

