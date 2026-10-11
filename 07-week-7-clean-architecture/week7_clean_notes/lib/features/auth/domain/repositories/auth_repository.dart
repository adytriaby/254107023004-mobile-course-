import '../../../../core/failures.dart';
import '../entities/session.dart';

abstract class AuthRepository {
  Future<({Session? session, Failure? failure})> login({
    required String email,
    required String password,
  });
  Future<({Session? session, Failure? failure})> restore();
  Future<void> logout();
}
