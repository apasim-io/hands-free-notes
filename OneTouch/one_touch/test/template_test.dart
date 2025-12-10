import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_touch/Objects/template.dart';
import 'package:one_touch/Objects/note.dart';

void main() {
  group('Unit Tests (Template)', () {
    test('constructor sets default name and generates id', () {
      final template = Template();
      expect(template.name, 'New Template');
      expect(template.id, isNotEmpty);
      expect(template.notes, isEmpty);
    });

    test('constructor accepts custom name and notes', () {
      final note = Note(noteType: NoteType.text, question: 'Test?');
      final template = Template(name: 'My Template', notes: [note]);

      expect(template.name, 'My Template');
      expect(template.notes.length, 1);
    });

    test('setName updates name', () {
      final template = Template();
      template.setName('Updated Name');
      expect(template.name, 'Updated Name');
    });

    test('add inserts a note', () {
      final template = Template();
      final note = Note(noteType: NoteType.text, question: 'Q1');

      template.add(note);

      expect(template.length, 1);
      expect(template.notes.first.question, 'Q1');
    });

    test('remove deletes a note and returns true', () {
      final note = Note(noteType: NoteType.text, question: 'Q1');
      final template = Template(notes: [note]);

      final result = template.remove(note);

      expect(result, isTrue);
      expect(template.length, 0);
    });

    test('remove returns false if note not found', () {
      final template = Template();
      final note = Note(noteType: NoteType.text, question: 'Q1');

      expect(template.remove(note), isFalse);
    });

    test('getAt returns note at valid index', () {
      final note = Note(noteType: NoteType.text, question: 'Q1');
      final template = Template(notes: [note]);

      expect(template.getAt(0), note);
    });

    test('getAt returns null for invalid index', () {
      final template = Template();

      expect(template.getAt(-1), isNull);
      expect(template.getAt(0), isNull);
      expect(template.getAt(100), isNull);
    });

    test('clear removes all notes', () {
      final template = Template(notes: [
        Note(noteType: NoteType.text, question: 'Q1'),
        Note(noteType: NoteType.text, question: 'Q2'),
      ]);

      template.clear();

      expect(template.length, 0);
    });
  });

  group('Unit Tests (Serialization)', () {
    test('toJson produces correct map', () {
      final template = Template(name: 'Test', notes: []);
      final json = template.toJson();

      expect(json['name'], 'Test');
      expect(json['id'], isNotEmpty);
      expect(json['notes'], isEmpty);
    });

    test('fromJson restores Template correctly', () {
      final json = {
        'name': 'Restored',
        'id': '12345',
        'notes': [],
      };

      final template = Template.fromJson(json);

      expect(template.name, 'Restored');
      expect(template.id, '12345');
      expect(template.notes, isEmpty);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};
      final template = Template.fromJson(json);

      expect(template.name, 'New Template');
      expect(template.id, '');
      expect(template.notes, isEmpty);
    });

    test('fromJson deserializes MultipleChoiceNote correctly', () {
      final json = {
        'name': 'Test',
        'id': '1',
        'notes': [
          {
            'noteType': 'multipleChoice',
            'question': 'Pick some',
            'options': ['A', 'B', 'C'],
            'maxSelections': 2,
          }
        ],
      };

      final template = Template.fromJson(json);

      expect(template.notes.first, isA<MultipleChoiceNote>());
      expect((template.notes.first as MultipleChoiceNote).options, ['A', 'B', 'C']);
    });

    test('fromJson deserializes SingleChoiceNote correctly', () {
      final json = {
        'name': 'Test',
        'id': '1',
        'notes': [
          {
            'noteType': 'singleChoice',
            'question': 'Pick one',
            'options': ['Yes', 'No'],
          }
        ],
      };

      final template = Template.fromJson(json);

      expect(template.notes.first, isA<SingleChoiceNote>());
    });

    test('round-trip serialization preserves data', () {
      final original = Template(
        name: 'Round Trip',
        notes: [
          MultipleChoiceNote(
            noteType: NoteType.multipleChoice,
            question: 'Choose',
            options: ['X', 'Y'],
            maxSelections: 1,
          ),
        ],
      );

      final json = original.toJson();
      final restored = Template.fromJson(json);

      expect(restored.name, original.name);
      expect(restored.notes.length, 1);
      expect(restored.notes.first.question, 'Choose');
    });

    test('clone creates independent copy', () {
      final original = Template(name: 'Original');
      original.add(Note(noteType: NoteType.text, question: 'Q1'));

      final cloned = original.clone();
      cloned.setName('Cloned');
      cloned.clear();

      expect(original.name, 'Original');
      expect(original.length, 1);
      expect(cloned.name, 'Cloned');
      expect(cloned.length, 0);
    });
  });

  group('Integration Tests (TemplateStorage)', () {
    late Directory tempDir;
    late File tempFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('template_test_');
      tempFile = File('${tempDir.path}/test_templates.json');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('saveTemplateData writes JSON to file', () async {
      final storage = TemplateStorage();
      final templates = [
        Template(name: 'T1').toJson(),
        Template(name: 'T2').toJson(),
      ];

      storage.saveTemplateData(templates, tempFile);
      await Future.delayed(Duration(milliseconds: 100));

      final content = await tempFile.readAsString();
      final decoded = jsonDecode(content) as List;

      expect(decoded.length, 2);
    });

    test('getTemplateData reads and parses templates', () async {
      final storage = TemplateStorage();
      final jsonData = jsonEncode([
        {'name': 'Loaded', 'id': '123', 'notes': []},
      ]);
      await tempFile.writeAsString(jsonData);

      final templates = await storage.getTemplateData(tempFile);

      expect(templates.length, 1);
      expect(templates.first.name, 'Loaded');
    });

    test('full save and load cycle preserves templates', () async {
      final storage = TemplateStorage();
      final original = Template(name: 'Full Cycle');
      original.add(SingleChoiceNote(
        noteType: NoteType.singleChoice,
        question: 'Yes?',
        options: ['Yes', 'No'],
      ));

      storage.saveTemplateData([original.toJson()], tempFile);
      await Future.delayed(Duration(milliseconds: 100));

      final loaded = await storage.getTemplateData(tempFile);

      expect(loaded.first.name, 'Full Cycle');
      expect(loaded.first.notes.first, isA<SingleChoiceNote>());
    });
  });
}