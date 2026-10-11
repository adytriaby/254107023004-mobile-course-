import '../../../../core/failures.dart';
import '../entities/session.dart';
import '../repositories/auth_repository.dart';

/// Use case: login dengan validasi aturan bisnis (email & panjang sandi).
class Login {
  const Login(this._repository);
  final AuthRepository _repository;

  Future<({Session? session, Failure? failure})> call({
    required String email,
    required String password,
  }) {
    final cleanEmail = email.trim();
    if (!cleanEmail.contains('@')) {
      return Future.value(
        (session: null, failure: const AuthFailure('Format email tidak valid')),
      );
    }
    if (password.length < 6) {
      return Future.value(
        (session: null,
          failure: const AuthFailure('Kata sandi minimal 6 karakter')),
      );
    }
    return _repository.login(email: cleanEmail, password: password);
  }
}
