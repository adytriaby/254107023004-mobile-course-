import 'repositories/note_repository.dart';

/// Sinkronisasi catatan kotor (dirty) ke "server".
///
/// Karena codelab ini belum punya backend tulis, server disimulasikan dengan
/// delay. Yang dinilai adalah mekanismenya: kirim catatan dirty, lalu tandai
/// bersih hanya setelah server menjawab sukses.
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}
