import 'package:json_annotation/json_annotation.dart';
import 'note.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

part 'template.g.dart';

class TemplateStorage {
  final templatesFName = 'templates.json';
  final sessionsFName = 'sessions.json';

  // get local path to documents on target device
  Future<String> localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> localFile(String fname) async {
    final path = await localPath();
    return File('$path/$fname');
  }

  void saveTemplateData(List templates, File file) {
    final jsonList = jsonEncode(templates);
    file.writeAsString(jsonList);
  }

  Future<List<Template>> getTemplateData(File file) async {
    final jsonString = await file.readAsString();
    List<dynamic> templateMap = jsonDecode(jsonString);
    List<Template> templates = templateMap.map((template) => Template.fromJson(template)).toList();
    return templates;
  }

  Future<List<Template>> getSampleTemplates(String filePath) async {
    final jsonString = await rootBundle.loadString(filePath);
    List<dynamic> templateMap = jsonDecode(jsonString);
    List<Template> templates = templateMap.map((template) => Template.fromJson(template)).toList();
    return templates;
  }
}

// a template containing multiple instances of notes
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

  // Add a note to the template.
  void add(Note note) => notes.add(note);

  // Remove a note from the session. Returns true if removed.
  bool remove(Note note) => notes.remove(note);

  // Return the note at [index], or null if index is out of range.
  Note? getAt(int index) => (index >= 0 && index < notes.length) ? notes[index] : null;

  // Remove all notes.
  void clear() => notes.clear();

  // Number of notes in the session.
  int get length => notes.length;

  @override
  String toString() => 'Template(notes: $notes)';

  // Serialization
  factory Template.fromJson(Map<String, dynamic> json) => _$TemplateFromJson(json);
  Map<String, dynamic> toJson() => _$TemplateToJson(this);
}

