import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local/note.dart';
import 'prefs.dart';
import 'repositories/note_repository.dart';
import 'repositories/post_cache_repository.dart';
import 'sync.dart';

final noteRepositoryProvider =
    Provider<NoteRepository>((ref) => NoteRepository());

final postCacheRepositoryProvider =
    Provider<PostCacheRepository>((ref) => PostCacheRepository());

final prefsRepositoryProvider =
    Provider<PrefsRepository>((ref) => PrefsRepository());

final dioProvider = Provider<Dio>((ref) => Dio(BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    )));

/// Daftar catatan (AsyncValue: loading/error/data) + operasi CRUD.
class NotesNotifier extends AsyncNotifier<List<Note>> {
  static const bool seed =
      bool.fromEnvironment('SEED_NOTES', defaultValue: false);

  /// `AUTO_SYNC=true` (dart-define) mensimulasikan sinkronisasi otomatis
  /// setelah seed, untuk memperlihatkan badge dirty kembali ke 0.
  static const bool autoSync =
      bool.fromEnvironment('AUTO_SYNC', defaultValue: false);

  @override
  Future<List<Note>> build() async {
    final repo = ref.watch(noteRepositoryProvider);
    var notes = await repo.fetchNotes();
    if (seed && notes.isEmpty) {
      await repo.addNote(
        title: 'Belanja mingguan',
        body: 'Beras, telur, sayur',
      );
      await repo.addNote(
        title: 'Catatan kuliah',
        body: 'Review materi Minggu 5',
      );
      await repo.addNote(title: 'Ide proyek akhir');
      if (autoSync) {
        await repo.markAllSynced();
      }
      notes = await repo.fetchNotes();
    }
    return notes;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(noteRepositoryProvider).fetchNotes(),
    );
  }

  Future<void> add(String title, {String body = ''}) async {
    await ref.read(noteRepositoryProvider).addNote(title: title, body: body);
    ref.invalidateSelf();
  }

  Future<void> updateNote(Note note) async {
    await ref.read(noteRepositoryProvider).updateNote(note);
    ref.invalidateSelf();
  }

  Future<void> remove(int id) async {
    await ref.read(noteRepositoryProvider).deleteNote(id);
    ref.invalidateSelf();
  }
}

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  retry: (retryCount, error) => null,
);

/// Jumlah catatan yang belum tersinkron (badge dirty).
final dirtyCountProvider = FutureProvider<int>((ref) async {
  ref.watch(notesProvider);
  return ref.watch(noteRepositoryProvider).countDirty();
});

/// Status sinkronisasi (idle/running/done) untuk umpan balik UI.
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
      final count = await syncNotes(ref.read(noteRepositoryProvider));
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

/// Preferensi tema gelap (disimpan di SharedPreferences).
class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

/// Waktu terakhir aplikasi dibuka.
final lastOpenedProvider = FutureProvider<String?>((ref) async {
  await ref.watch(prefsRepositoryProvider).markOpenedNow();
  return ref.watch(prefsRepositoryProvider).getLastOpened();
});

/// Cache-first read untuk data post: baca cache lokal dulu.
///
/// `SEED_CACHE=true` (dart-define) mengisi cache dengan data contoh agar
/// pola cache-first (tampil tanpa internet) dapat didemonstrasikan.
final cachedPostsProvider =
    FutureProvider<List<Map<String, Object?>>>((ref) async {
  const seedCache = bool.fromEnvironment('SEED_CACHE', defaultValue: false);
  final cache = ref.watch(postCacheRepositoryProvider);
  if (seedCache) {
    final existing = await cache.readCachedPosts();
    if (existing.isEmpty) {
      final now = DateTime.now().toIso8601String();
      await cache.saveCachedPosts([
        for (var i = 1; i <= 5; i++)
          {
            'id': i,
            'payload': 'Post cache $i',
            'cached_at': now,
          },
      ]);
    }
  }
  return cache.readCachedPosts();
});

final lastCachedAtProvider = FutureProvider<DateTime?>((ref) async {
  ref.watch(cachedPostsProvider);
  return ref.watch(postCacheRepositoryProvider).lastCachedAt();
});
