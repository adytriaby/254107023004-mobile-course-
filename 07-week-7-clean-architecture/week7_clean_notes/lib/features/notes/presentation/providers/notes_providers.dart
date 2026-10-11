import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/sync_notes.dart';

// ---- Data layer: implementasi disuntikkan ----
final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepositoryImpl(),
);

// ---- Domain layer: use case menerima abstraksi, bukan implementasi ----
final getNotesProvider =
    Provider<GetNotes>((ref) => GetNotes(ref.watch(noteRepositoryProvider)));

final addNoteProvider =
    Provider<AddNote>((ref) => AddNote(ref.watch(noteRepositoryProvider)));

final syncNotesProvider =
    Provider<SyncNotes>((ref) => SyncNotes(ref.watch(noteRepositoryProvider)));

// ---- Presentation layer: state untuk UI ----
class NotesNotifier extends AsyncNotifier<List<Note>> {
  static const bool seed =
      bool.fromEnvironment('SEED_NOTES', defaultValue: false);

  @override
  Future<List<Note>> build() async {
    final getNotes = ref.watch(getNotesProvider);
    if (seed) {
      final current = await getNotes.call();
      if (current.notes.isEmpty) {
        final addNote = ref.read(addNoteProvider);
        await addNote.call(title: 'Belanja mingguan', body: 'Beras, telur, sayur');
        await addNote.call(title: 'Catatan kuliah', body: 'Review Clean Architecture');
        await addNote.call(title: 'Ide proyek akhir');
      }
    }
    final result = await getNotes.call();
    if (result.failure != null) throw Exception(result.failure!.message);
    return result.notes;
  }

  Future<void> add(String title, {String body = ''}) async {
    final result = await ref.read(addNoteProvider).call(title: title, body: body);
    if (result.failure != null) throw Exception(result.failure!.message);
    ref.invalidateSelf();
  }

  Future<void> remove(int id) async {
    await ref.read(noteRepositoryProvider).deleteNote(id);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  retry: (retryCount, error) => null,
);

final dirtyCountProvider = FutureProvider<int>((ref) async {
  ref.watch(notesProvider);
  return ref.watch(noteRepositoryProvider).countDirty();
});

class SyncState {
  const SyncState({this.running = false, this.lastSynced = 0, this.error});
  final bool running;
  final int lastSynced;
  final Object? error;
}

class SyncNotifier extends Notifier<SyncState> {
  @override
  SyncState build() => const SyncState();

  Future<void> run() async {
    state = const SyncState(running: true);
    try {
      final count = await ref.read(syncNotesProvider).call();
      ref.invalidate(notesProvider);
      ref.invalidate(dirtyCountProvider);
      state = SyncState(lastSynced: count);
    } catch (e) {
      state = SyncState(error: e);
    }
  }
}

final syncProvider =
    NotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);
