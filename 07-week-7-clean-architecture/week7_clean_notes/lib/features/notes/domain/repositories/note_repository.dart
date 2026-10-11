import '../../../../core/failures.dart';
import '../entities/note.dart';

/// Kontrak yang dibutuhkan domain. Implementasi ada di layer data.
abstract class NoteRepository {
  Future<({List<Note> notes, Failure? failure})> fetchNotes();
  Future<({Note? note, Failure? failure})> fetchNote(int id);
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body,
  });
  Future<Failure?> deleteNote(int id);
  Future<int> countDirty();
  Future<Failure?> markAllSynced();
}
