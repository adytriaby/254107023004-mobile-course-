import '../../../../core/failures.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementasi auth (data layer). Mock yang siap diganti backend nyata.
class AuthRepositoryImpl implements AuthRepository {
  Session? _current;

  @override
  Future<({Session? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Demo: kredensial apa pun yang lolos validasi dianggap sah.
    final session = Session(
      email: email,
      accessToken: 'mock-access-${DateTime.now().millisecondsSinceEpoch}',
    );
    _current = session;
    return (session: session, failure: null);
  }

  @override
  Future<({Session? session, Failure? failure})> restore() async {
    return (session: _current, failure: null);
  }

  @override
  Future<void> logout() async {
    _current = null;
  }
}
