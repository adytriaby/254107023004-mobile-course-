import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(),
);

final loginUseCaseProvider =
    Provider<Login>((ref) => Login(ref.watch(authRepositoryProvider)));

class AuthState {
  const AuthState({this.loggedIn = false, this.email});
  final bool loggedIn;
  final String? email;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<String?> login(String email, String password) async {
    final result = await ref
        .read(loginUseCaseProvider)
        .call(email: email, password: password);
    if (result.failure != null) return result.failure!.message;
    state = AuthState(loggedIn: true, email: result.session!.email);
    return null;
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState();
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
