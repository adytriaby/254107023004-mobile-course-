import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_client.dart';
import '../data/auth_repository.dart';
import '../data/token_store.dart';

final tokenStoreProvider =
    Provider<TokenStorage>((ref) => SecureTokenStore());

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());

final apiClientProvider = Provider<Dio>((ref) {
  return buildApiClient(
    ref.watch(tokenStoreProvider),
    ref.watch(authRepositoryProvider),
  );
});

/// Status login. `AUTO_LOGIN=true` (dart-define) dipakai untuk demo/screenshot.
class AuthNotifier extends AsyncNotifier<bool> {
  static const bool autoLogin =
      bool.fromEnvironment('AUTO_LOGIN', defaultValue: false);

  @override
  Future<bool> build() async {
    final store = ref.watch(tokenStoreProvider);
    final token = await store.readAccess();
    if (token != null) return true;
    if (autoLogin) {
      final session = await ref.read(authRepositoryProvider).login(
            email: 'mahasiswa@polinema.ac.id',
            password: 'polinema123',
          );
      await store.save(access: session.access, refresh: session.refresh);
      return true;
    }
    return false;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStoreProvider)
          .save(access: session.access, refresh: session.refresh);
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(false);
  }
}

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);
