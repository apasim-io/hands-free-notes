import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_touch/Objects/template.dart';
import 'package:one_touch/Objects/note.dart';
import 'package:one_touch/Pages/template_create.dart';

void main() {
  group('Widget Tests', () {
    late Template mockTemplate;
    late List<Map<String, dynamic>> callbackCalls;

    setUp(() {
      mockTemplate = Template(id: 'test-id', name: 'My Template');
      callbackCalls = [];
    });

    void mockCallback(Template template, String action) {
      callbackCalls.add({'template': template, 'action': action});
    }

    testWidgets('displays template name in AppBar TextField', (tester) async {
      await tester.pumpWidget(MaterialApp(home: TemplateCreate(
        template: mockTemplate, saveTemplatesCallback: mockCallback)));

      expect(find.widgetWithText(TextField, 'My Template'), findsOneWidget);
    });

    testWidgets('shows New note button when no notes exist', (tester) async {
      await tester.pumpWidget(MaterialApp(home: TemplateCreate(
        template: mockTemplate, saveTemplatesCallback: mockCallback)));

      expect(find.text('New note'), findsWidgets);
    });

    testWidgets('tapping New note adds a note to the list', (tester) async {
      await tester.pumpWidget(MaterialApp(home: TemplateCreate(
        template: mockTemplate, saveTemplatesCallback: mockCallback)));

      await tester.tap(find.text('New note').first);
      await tester.pump();

      expect(find.text('Question text'), findsOneWidget);
    });

    testWidgets('Next button shows Finish on last note', (tester) async {
      mockTemplate.add(MultipleChoiceNote(
        noteType: NoteType.multipleChoice, question: 'Only note',
        options: ['A', 'B'], maxSelections: 1));

      await tester.pumpWidget(MaterialApp(home: TemplateCreate(
        template: mockTemplate, saveTemplatesCallback: mockCallback)));

      await tester.tap(find.text('Only note'));
      await tester.pump();

      expect(find.text('Finish'), findsOneWidget);
    });

    testWidgets('tapping a note selects it', (tester) async {
      mockTemplate.add(MultipleChoiceNote(
        noteType: NoteType.multipleChoice, question: 'First',
        options: ['A'], maxSelections: 1));
      mockTemplate.add(MultipleChoiceNote(
        noteType: NoteType.multipleChoice, question: 'Second',
        options: ['B'], maxSelections: 1));

      await tester.pumpWidget(MaterialApp(home: TemplateCreate(
        template: mockTemplate, saveTemplatesCallback: mockCallback)));

      await tester.tap(find.text('Second'));
      await tester.pump();

      expect(tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Second')).selected, isTrue);
    });
  });

  group('Integration Tests', () {
    late Template mockTemplate;
    late List<Map<String, dynamic>> callbackCalls;

    setUp(() {
      mockTemplate = Template(id: 'test-id', name: 'My Template');
      callbackCalls = [];
    });

    void mockCallback(Template template, String action) {
      callbackCalls.add({'template': template, 'action': action});
    }

    Widget wrappedInNavigator() => MaterialApp(
      home: Scaffold(body: Builder(builder: (context) => ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => TemplateCreate(
            template: mockTemplate, saveTemplatesCallback: mockCallback))),
        child: const Text('Go')))));

    testWidgets('Save triggers callback with updated name', (tester) async {
      await tester.pumpWidget(MaterialApp(home: TemplateCreate(
        template: mockTemplate, saveTemplatesCallback: mockCallback)));

      await tester.enterText(find.byType(TextField), 'Renamed');
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(callbackCalls[0]['action'], 'save');
      expect(callbackCalls[0]['template'].name, 'Renamed');
    });

    testWidgets('Exit triggers revert callback and pops', (tester) async {
      await tester.pumpWidget(wrappedInNavigator());
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();

      expect(callbackCalls[0]['action'], 'revert');
      expect(find.byType(TemplateCreate), findsNothing);
    });

    testWidgets('Delete triggers delete callback and pops', (tester) async {
      await tester.pumpWidget(wrappedInNavigator());
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(callbackCalls[0]['action'], 'delete');
      expect(find.byType(TemplateCreate), findsNothing);
    });
  });
}