import 'note.dart';
import 'package:flutter/material.dart';

// a page of notes within a session
class Page {
  final List<Note> notes;

  Page({List<Note>? notes}) : notes = notes ?? [];

  // Add a note to the session.
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
  String toString() => 'Session(notes: $notes)';
}

// a session containing multiple pages of notes
class Session {
  String name = "New Session";
  final List<Page> notes;

  Session({List<Page>? notes}) : notes = notes ?? [];

  // Add a page to the session.
  void add(Page page) => notes.add(page);

  //
  void setName(String newName) {
    name = newName;
  }

  // Remove a page from the session. Returns true if removed.
  bool remove(Page page) => notes.remove(page);

  // Return the page at [index], or null if index is out of range.
  Page? getAt(int index) => (index >= 0 && index < notes.length) ? notes[index] : null;

  // Remove all pages.
  void clear() => notes.clear();

  // Number of pages in the session.
  int get length => notes.length;

  @override
  String toString() => 'Session(notes: $notes)';

}

