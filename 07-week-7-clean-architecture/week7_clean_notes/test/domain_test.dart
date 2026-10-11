import 'package:flutter_test/flutter_test.dart';

import 'package:week7_clean_notes/core/failures.dart';
import 'package:week7_clean_notes/core/format.dart';
import 'package:week7_clean_notes/features/notes/domain/entities/note.dart';
import 'package:week7_clean_notes/features/notes/domain/repositories/note_repository.dart';
import 'package:week7_clean_notes/features/notes/domain/usecases/add_note.dart';
import 'package:week7_clean_notes/features/notes/domain/usecases/get_notes.dart';
import 'package:week7_clean_notes/features/auth/domain/entities/session.dart';
import 'package:week7_clean_notes/features/auth/domain/repositories/auth_repository.dart';
import 'package:week7_clean_notes/features/auth/domain/usecases/login.dart';

/// Fake repository notes — mengimplementasikan interface domain, tanpa SQLite.
class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.items = const [], this.fail = false});

  final List<Note> items;
  final bool fail;
  int addCalls = 0;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (fail) {
      return (
        notes: const <Note>[],
        failure: const LocalFailure('db locked (simulasi)'),
      );
    }
    return (notes: items, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> fetchNote(int id) async =>
      (note: null, failure: null);

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    addCalls++;
    return (
      note: Note(title: title, body: body, updatedAt: DateTime.now()),
      failure: null,
    );
  }

  @override
  Future<Failure?> deleteNote(int id) async => null;

  @override
  Future<int> countDirty() async => items.where((n) => n.dirty).length;

  @override
  Future<Failure?> markAllSynced() async => null;
}

/// Fake repository auth.
class FakeAuthRepository implements AuthRepository {
  int loginCalls = 0;

  @override
  Future<({Session? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    return (
      session: Session(email: email, accessToken: 'token'),
      failure: null,
    );
  }

  @override
  Future<({Session? session, Failure? failure})> restore() async =>
      (session: null, failure: null);

  @override
  Future<void> logout() async {}
}

void main() {
  group('GetNotes', () {
    test('meneruskan daftar dari repository', () async {
      final repo = FakeNoteRepository(items: [
        Note(title: 'A', updatedAt: DateTime(2026, 9, 27)),
      ]);
      final result = await GetNotes(repo).call();
      expect(result.failure, isNull);
      expect(result.notes.length, 1);
      expect(result.notes.first.title, 'A');
    });

    test('meneruskan failure tanpa melempar', () async {
      final repo = FakeNoteRepository(fail: true);
      final result = await GetNotes(repo).call();
      expect(result.failure, isA<LocalFailure>());
      expect(result.notes, isEmpty);
    });
  });

  group('AddNote', () {
    test('menolak judul kosong tanpa memanggil repository', () async {
      final repo = FakeNoteRepository();
      final result = await AddNote(repo).call(title: '   ');
      expect(result.failure, isA<LocalFailure>());
      expect(repo.addCalls, 0);
    });

    test('men-trim judul dan meneruskan ke repository', () async {
      final repo = FakeNoteRepository();
      final result = await AddNote(repo).call(title: '  Belanja  ');
      expect(result.failure, isNull);
      expect(result.note!.title, 'Belanja');
      expect(repo.addCalls, 1);
    });
  });

  group('Login', () {
    test('menolak email tanpa @', () async {
      final repo = FakeAuthRepository();
      final result = await Login(repo).call(email: 'salah', password: '123456');
      expect(result.failure, isA<AuthFailure>());
      expect(repo.loginCalls, 0);
    });

    test('menolak sandi pendek', () async {
      final repo = FakeAuthRepository();
      final result =
          await Login(repo).call(email: 'a@b.com', password: '123');
      expect(result.failure, isA<AuthFailure>());
      expect(repo.loginCalls, 0);
    });

    test('login sukses memanggil repository', () async {
      final repo = FakeAuthRepository();
      final result = await Login(repo)
          .call(email: 'a@b.com', password: '123456');
      expect(result.failure, isNull);
      expect(result.session!.email, 'a@b.com');
      expect(repo.loginCalls, 1);
    });
  });

  group('formatDate', () {
    test('memformat tanggal Indonesia', () {
      expect(formatDate(DateTime(2026, 10, 5)), '05 Okt 2026');
    });
  });
}
