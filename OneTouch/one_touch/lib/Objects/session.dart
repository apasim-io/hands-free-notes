import 'note.dart';

// a page of notes within a session
class Page {
  String pageTitle = "";
  String pageContent = ""; // should be a description or summary of the page
  final List<Note> notes;

  
  Page({List<Note>? notes, String? pageTitle, String? pageContent})
      : notes = notes ?? [] {
    if (pageTitle != null) this.pageTitle = pageTitle;
    if (pageContent != null) this.pageContent = pageContent;
  }

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


  /// Create a Page from a decoded JSON map. Handles mapping each note to the
  /// appropriate Note subclass based on the `note_type` string.
  Page.fromJson(Map<String, dynamic> json)
      : pageTitle = json['page_title'] ?? json['pageTitle'] ?? json['title'] ?? '',
        pageContent = json['section_content'] ?? json['page_content'] ?? json['pageContent'] ?? '',
        notes = (json['notes'] as List<dynamic>?)
                ?.map((e) {
                  if (e is Map<String, dynamic>) {
                    final type = (e['note_type'] ?? '').toString();
                    switch (type) {
                      case 'numberScale':
                        return NumberScaleNote.fromJson(e);
                      case 'multipleChoice':
                        return MultipleChoiceNote.fromJson(e);
                      case 'singleChoice':
                        return SingleChoiceNote.fromJson(e);
                      default:
                        return Note.fromJson(e);
                    }
                  }
                  return Note.fromJson({});
                }).toList() ??
            [];
}

// a session containing multiple pages of notes
class Session {
  String name = "New Session";
  final List<Page> pages;

  Session({List<Page>? pages, String? name}) : pages = pages ?? []{
    if (name != null) this.name = name;
  }

  void setName(String newName) {
    name = newName;
  }

  // Add a page to the session.
  void add(Page page) => pages.add(page);

  // Remove a page from the session. Returns true if removed.
  bool remove(Page page) => pages.remove(page);

  // Return the page at [index], or null if index is out of range.
  Page? getAt(int index) => (index >= 0 && index < pages.length) ? pages[index] : null;

  // Remove all pages.
  void clear() => pages.clear();

  // Number of pages in the session.
  int get length => pages.length;

  @override
  String toString() => 'Session(notes: $pages)';

  Session.fromJson(Map<String, dynamic> json):
    name = json['name'] ?? 'New Session',
    pages = (json['pages'] as List<dynamic>?)
            ?.map((e) => Page.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

}

