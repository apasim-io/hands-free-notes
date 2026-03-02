import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_touch/Objects/template.dart';
import 'package:one_touch/Objects/note.dart';
import 'package:one_touch/Pages/note_session.dart';

void main() {
  group('Widget Tests', () {
    late Template mockTemplate;
    late List<Map<String, dynamic>> callbackCalls;

    setUp(() {
      mockTemplate = Template(id: 'test-id', name: 'My Session');
      callbackCalls = [];
    });

    void mockCallback(Template template, String action) {
      callbackCalls.add({'template': template, 'action': action});
    }

    testWidgets('displays template name in AppBar via RichText', (tester) async {
      await tester.pumpWidget(MaterialApp(home: NoteSession(
        template: mockTemplate, saveTemplatesCallback: mockCallback)));

      expect(find.byWidgetPredicate((w) =>
        w is RichText && (w.text as TextSpan).toPlainText().contains('My Session')),
        findsOneWidget);
    });

    testWidgets('shows Select a note when nothing is selected', (tester) async {
      mockTemplate.add(SingleChoiceNote(
        noteType: NoteType.singleChoice, question: 'Pick one', options: ['A', 'B']));

      await tester.pumpWidget(MaterialApp(home: NoteSession(
        template: mockTemplate, saveTemplatesCallback: mockCallback)));

      expect(find.text('Select a note'), findsOneWidget);
    });

    testWidgets('tapping a note hides Select a note prompt', (tester) async {
      mockTemplate.add(SingleChoiceNote(
        noteType: NoteType.singleChoice, question: 'Pick one', options: ['A', 'B']));

      await tester.pumpWidget(MaterialApp(home: NoteSession(
        template: mockTemplate, saveTemplatesCallback: mockCallback)));

      await tester.tap(find.text('Pick one'));
      await tester.pump();

      expect(find.text('Select a note'), findsNothing);
    });

    testWidgets('Next button shows Finish on last note', (tester) async {
      mockTemplate.add(SingleChoiceNote(
        noteType: NoteType.singleChoice, question: 'Only note', options: ['A']));

      await tester.pumpWidget(MaterialApp(home: NoteSession(
        template: mockTemplate, saveTemplatesCallback: mockCallback)));

      await tester.tap(find.text('Only note'));
      await tester.pump();

      expect(find.text('Finish'), findsOneWidget);
    });

    testWidgets('Next advances selection to next note', (tester) async {
      mockTemplate.add(SingleChoiceNote(
        noteType: NoteType.singleChoice, question: 'First', options: ['A']));
      mockTemplate.add(SingleChoiceNote(
        noteType: NoteType.singleChoice, question: 'Second', options: ['B']));

      await tester.pumpWidget(MaterialApp(home: NoteSession(
        template: mockTemplate, saveTemplatesCallback: mockCallback)));

      await tester.tap(find.text('First'));
      await tester.pump();
      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Second')).selected, isTrue);
    });
  });

  group('Integration Tests', () {
    late Template mockTemplate;
    late List<Map<String, dynamic>> callbackCalls;

    setUp(() {
      mockTemplate = Template(id: 'test-id', name: 'My Session');
      callbackCalls = [];
    });

    void mockCallback(Template template, String action) {
      callbackCalls.add({'template': template, 'action': action});
    }

    Widget wrappedInNavigator() => MaterialApp(
      home: Scaffold(body: Builder(builder: (context) => ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => NoteSession(
            template: mockTemplate, saveTemplatesCallback: mockCallback))),
        child: const Text('Go')))));

    testWidgets('Save triggers callback without popping', (tester) async {
      await tester.pumpWidget(MaterialApp(home: NoteSession(
        template: mockTemplate, saveTemplatesCallback: mockCallback)));

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(callbackCalls[0]['action'], 'save');
      expect(find.byType(NoteSession), findsOneWidget);
    });

    testWidgets('Finish triggers save callback and pops', (tester) async {
      mockTemplate.add(SingleChoiceNote(
        noteType: NoteType.singleChoice, question: 'Last', options: ['A']));

      await tester.pumpWidget(wrappedInNavigator());
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Last'));
      await tester.pump();
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      expect(callbackCalls[0]['action'], 'save');
      expect(find.byType(NoteSession), findsNothing);
    });

    testWidgets('Exit triggers revert callback and pops', (tester) async {
      await tester.pumpWidget(wrappedInNavigator());
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();

      expect(callbackCalls[0]['action'], 'revert');
      expect(find.byType(NoteSession), findsNothing);
    });
  });
}