import 'package:dio/dio.dart';

import 'auth_repository.dart';
import 'token_store.dart';

const _retriedKey = 'retried_after_refresh';

/// Membuat Dio dengan interceptor: menyisipkan Bearer token dan mencoba
/// refresh **satu kali** saat menerima 401, lalu mengulang request.
Dio buildApiClient(TokenStorage store, AuthRepository auth) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example-campus-api.test'));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        final is401 = e.response?.statusCode == 401;
        final alreadyRetried = e.requestOptions.extra[_retriedKey] == true;

        if (is401 && !alreadyRetried) {
          final refresh = await store.readRefresh();
          if (refresh == null) return handler.next(e);
          try {
            final renewed = await auth.refresh(refresh);
            await store.save(access: renewed, refresh: refresh);
            final options = e.requestOptions
              ..headers['Authorization'] = 'Bearer $renewed'
              ..extra[_retriedKey] = true;
            final retry = await dio.fetch(options);
            return handler.resolve(retry);
          } catch (_) {
            await store.clear(); // refresh ikut mati -> paksa login ulang
          }
        }
        handler.next(e);
      },
    ),
  );

  return dio;
}
