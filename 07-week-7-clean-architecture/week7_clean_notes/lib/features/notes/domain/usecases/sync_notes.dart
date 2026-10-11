import '../repositories/note_repository.dart';

/// Use case: sinkronisasi catatan kotor (dirty) — menggabungkan >1 operasi
/// repository sehingga use case memang diperlukan (bukan CRUD satu-baris).
class SyncNotes {
  const SyncNotes(this._repository);
  final NoteRepository _repository;

  /// Mengembalikan jumlah catatan yang berhasil disinkronkan.
  Future<int> call() async {
    final dirtyCount = await _repository.countDirty();
    if (dirtyCount == 0) return 0;
    // Simulasi upload ke server; pada project nyata kirim tiap note dirty.
    await Future.delayed(const Duration(seconds: 1));
    await _repository.markAllSynced();
    return dirtyCount;
  }
}
