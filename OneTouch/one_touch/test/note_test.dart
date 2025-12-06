import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_touch/Objects/note.dart';

void main() {
  group('Unit Tests', () {
    group('NumberScaleNote', () {
      test('getValueString returns value as string', () {
        final note = NumberScaleNote(
          noteType: NoteType.numberScale,
          question: 'Rate your mood',
          minValue: 0,
          maxValue: 10,
          step: 1,
          minLabel: 'Bad',
          maxLabel: 'Good',
        );
        note.value = 7;
        expect(note.getValueString(), '7');
      });

      test('markInteraction sets interactionTime', () {
        final note = NumberScaleNote(
          noteType: NoteType.numberScale,
          question: 'Rate your mood',
          minValue: 0,
          maxValue: 10,
          step: 1,
          minLabel: 'Low',
          maxLabel: 'High',
        );
        expect(note.interactionTime, isNull);
        note.markInteraction();
        expect(note.interactionTime, isNotNull);
      });

      test('toJson and fromJson round-trip correctly', () {
        final note = NumberScaleNote(
          noteType: NoteType.numberScale,
          question: 'Test question',
          minValue: 1,
          maxValue: 5,
          step: 1,
          minLabel: 'Min',
          maxLabel: 'Max',
        );
        note.value = 3;

        final json = note.toJson();
        final restored = NumberScaleNote.fromJson(json);

        expect(restored.question, 'Test question');
        expect(restored.minValue, 1);
        expect(restored.maxValue, 5);
        expect(restored.value, 3);
      });
    });

    group('MultipleChoiceNote', () {
      test('getValueString returns selected options', () {
        final note = MultipleChoiceNote(
          noteType: NoteType.multipleChoice,
          question: 'Select number',
          options: ['One', 'Two', 'Three'],
          maxSelections: 3,
        );
        note.selection = [0, 2];
        expect(note.getValueString(), 'One, Three');
      });

      test('getValueString returns message when no selection', () {
        final note = MultipleChoiceNote(
          noteType: NoteType.multipleChoice,
          question: 'Select number',
          options: ['One', 'Two'],
          maxSelections: 2,
        );
        expect(note.getValueString(), 'No selections made.');
      });
    });

    group('SingleChoiceNote', () {
      test('getValueString returns selected option', () {
        final note = SingleChoiceNote(
          noteType: NoteType.singleChoice,
          question: 'Pick one',
          options: ['Yes', 'No', 'Maybe'],
        );
        note.selection = 1;
        expect(note.getValueString(), 'No');
      });

      test('getValueString returns message when no selection', () {
        final note = SingleChoiceNote(
          noteType: NoteType.singleChoice,
          question: 'Pick one',
          options: ['Yes', 'No'],
        );
        expect(note.getValueString(), 'No selection made.');
      });
    });
  });
  group('Widget Tests', () {
    testWidgets('NumberScaleNote slider renders and updates', (tester) async {
      final note = NumberScaleNote(
        noteType: NoteType.numberScale,
        question: 'Rate it',
        minValue: 0,
        maxValue: 10,
        step: 1,
        minLabel: 'Low',
        maxLabel: 'High',
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: note.toGui())));

      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('Low'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('MultipleChoiceNote displays all options', (tester) async {
      final note = MultipleChoiceNote(
        noteType: NoteType.multipleChoice,
        question: 'Choose',
        options: ['A', 'B', 'C'],
        maxSelections: 2,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: note.toGui())));

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('MultipleChoiceNote tapping selects option', (tester) async {
      final note = MultipleChoiceNote(
        noteType: NoteType.multipleChoice,
        question: 'Choose',
        options: ['A', 'B'],
        maxSelections: 2,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: note.toGui())));

      await tester.tap(find.text('A'));
      await tester.pump();

      expect(note.selection, contains(0));
    });

    testWidgets('MultipleChoiceNote respects maxSelections', (tester) async {
      final note = MultipleChoiceNote(
        noteType: NoteType.multipleChoice,
        question: 'Choose',
        options: ['A', 'B', 'C'],
        maxSelections: 1,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: note.toGui())));

      await tester.tap(find.text('A'));
      await tester.pump();
      await tester.tap(find.text('B'));
      await tester.pump();

      expect(note.selection?.length, 1);
    });

    testWidgets('SingleChoiceNote tapping selects one option', (tester) async {
      final note = SingleChoiceNote(
        noteType: NoteType.singleChoice,
        question: 'Pick',
        options: ['X', 'Y'],
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: note.toGui())));

      await tester.tap(find.text('Y'));
      await tester.pump();

      expect(note.selection, 1);
    });

    testWidgets('SingleChoiceNote tapping again deselects', (tester) async {
      final note = SingleChoiceNote(
        noteType: NoteType.singleChoice,
        question: 'Pick',
        options: ['X', 'Y'],
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: note.toGui())));

      await tester.tap(find.text('X'));
      await tester.pump();
      await tester.tap(find.text('X'));
      await tester.pump();

      expect(note.selection, isNull);
    });
  });

  group('Integration Tests', () {
    testWidgets('interact then serialize preserves state', (tester) async {
      final note = MultipleChoiceNote(
        noteType: NoteType.multipleChoice,
        question: 'Numbers',
        options: ['One', 'Two', 'Three'],
        maxSelections: 2,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: note.toGui())));

      await tester.tap(find.text('One'));
      await tester.pump();
      await tester.tap(find.text('Three'));
      await tester.pump();

      final json = note.toJson();
      final restored = MultipleChoiceNote.fromJson(json);

      expect(restored.selection, containsAll([0, 2]));
      expect(restored.interactionTime, isNotNull);
    });

    testWidgets('full round-trip: create, interact, serialize, restore', (tester) async {
      final original = SingleChoiceNote(
        noteType: NoteType.singleChoice,
        question: 'Yes or No?',
        options: ['Yes', 'No'],
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: original.toGui())));
      await tester.tap(find.text('Yes'));
      await tester.pump();

      final json = original.toJson();
      final restored = SingleChoiceNote.fromJson(json);

      expect(restored.question, 'Yes or No?');
      expect(restored.selection, 0);
      expect(restored.getValueString(), 'Yes');
    });
  });
}