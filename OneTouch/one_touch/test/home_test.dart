import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_touch/Objects/template.dart';
import 'package:one_touch/Pages/home_page.dart';
import 'package:one_touch/Pages/note_session.dart';
import 'package:one_touch/Pages/session_create.dart';
import 'package:one_touch/Pages/template_create.dart';

void main() {
  Widget buildHome({List<Template>? sessions, List<Template>? templates}) =>
    MaterialApp(home: HomePage(
      initialTemplates: templates ?? [],
      initialSessions: sessions ?? []));

  group('Widget Tests', () {
    testWidgets('displays OneTouch in AppBar', (tester) async {
      await tester.pumpWidget(buildHome());
      expect(find.text('OneTouch'), findsOneWidget);
    });

    testWidgets('displays both section headings', (tester) async {
      await tester.pumpWidget(buildHome());
      expect(find.text('Recent Sessions'), findsOneWidget);
      expect(find.text('Start session from template'), findsOneWidget);
    });

    testWidgets('displays Create new Template button', (tester) async {
      await tester.pumpWidget(buildHome());
      expect(find.text('Create new Template'), findsOneWidget);
    });

    testWidgets('renders template names in template list', (tester) async {
      await tester.pumpWidget(buildHome(
        templates: [Template(name: 'My Template')]));
      expect(find.text('My Template'), findsOneWidget);
    });

    testWidgets('renders session names in session list', (tester) async {
      await tester.pumpWidget(buildHome(
        sessions: [Template(name: 'My Session')]));
      expect(find.text('My Session'), findsOneWidget);
    });
  });

  group('Integration Tests', () {
    testWidgets('Create new Template navigates to TemplateCreate', (tester) async {
      await tester.pumpWidget(buildHome());
      await tester.tap(find.text('Create new Template'));
      await tester.pumpAndSettle();
      expect(find.byType(TemplateCreate), findsOneWidget);
    });

    testWidgets('tapping a session navigates to NoteSession', (tester) async {
      await tester.pumpWidget(buildHome(
        sessions: [Template(name: 'My Session')]));
      await tester.tap(find.text('My Session'));
      await tester.pumpAndSettle();
      expect(find.byType(NoteSession), findsOneWidget);
    });

    testWidgets('tapping a template navigates to SessionCreate', (tester) async {
      await tester.pumpWidget(buildHome(
        templates: [Template(name: 'My Template')]));
      await tester.tap(find.text('My Template'));
      await tester.pumpAndSettle();
      expect(find.byType(SessionCreate), findsOneWidget);
    });
  });
}
