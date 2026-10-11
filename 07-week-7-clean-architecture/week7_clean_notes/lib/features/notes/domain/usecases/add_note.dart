import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Use case: menambah catatan dengan validasi aturan bisnis.
///
/// Use case dipakai di sini karena ada aturan bisnis (judul tidak boleh kosong
/// dan di-trim) — bukan sekadar meneruskan panggilan CRUD.
class AddNote {
  const AddNote(this._repository);
  final NoteRepository _repository;

  Future<({Note? note, Failure? failure})> call({
    required String title,
    String body = '',
  }) {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      return Future.value(
        (note: null, failure: const LocalFailure('Judul tidak boleh kosong')),
      );
    }
    return _repository.addNote(title: cleanTitle, body: body.trim());
  }
}
