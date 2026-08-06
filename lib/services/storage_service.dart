import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

/// Storage Service responsible for saving and reading notes locally
/// using SharedPreferences. No internet connection or remote database required.
class StorageService {
  static const String _storageKey = 'user_notes_list_v1';

  Future<List<Note>> getNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      return Note.decodeList(jsonString);
    } catch (e) {
      print('Error loading local notes: $e');
      return [];
    }
  }

  Future<bool> saveNotes(List<Note> notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = Note.encodeList(notes);
      return await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error saving local notes: $e');
      return false;
    }
  }

  Future<List<Note>> saveSingleNote(Note note) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      notes[index] = note;
    } else {
      notes.insert(0, note);
    }
    await saveNotes(notes);
    return notes;
  }

  Future<List<Note>> deleteNote(String noteId) async {
    final notes = await getNotes();
    notes.removeWhere((n) => n.id == noteId);
    await saveNotes(notes);
    return notes;
  }

  Future<bool> clearAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_storageKey);
  }
}
