import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_notify/data/api_client.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/routes.dart';

/// Adapter palsu: mengembalikan 401 saat memakai token "expired", 200 saat
/// memakai token baru. Mencatat berapa kali request diterima.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter({this.expiredToken = 'expired'});

  final String expiredToken;
  int calls = 0;
  final List<String?> seenAuth = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    final auth = options.headers['Authorization'] as String?;
    seenAuth.add(auth);
    if (auth == 'Bearer $expiredToken') {
      return ResponseBody.fromString('', 401, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      });
    }
    return ResponseBody.fromString('{"ok":true}', 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

/// Auth palsu: refresh mengembalikan token baru, atau gagal bila diminta.
class FakeAuth extends AuthRepository {
  FakeAuth({this.failRefresh = false});
  final bool failRefresh;
  int refreshCalls = 0;

  @override
  Future<String> refresh(String refreshToken) async {
    refreshCalls++;
    if (failRefresh) throw Exception('refresh mati');
    return 'renewed';
  }
}

void main() {
  group('routeFromMessage', () {
    test('route kosong -> /', () {
      expect(routeFromMessage({}), '/');
      expect(routeFromMessage({'route': ''}), '/');
    });

    test('route tanpa slash ditambahkan', () {
      expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    });

    test('route dengan slash dipertahankan', () {
      expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
    });

    test('data payload membawa id', () {
      const data = {'route': '/pengumuman/3', 'id': '3'};
      expect(data['id'], '3');
      expect(routeFromMessage(data), '/pengumuman/3');
    });
  });

  group('token storage (fake)', () {
    test('sesi hilang bila refresh kosong -> paksa login ulang', () async {
      final store = InMemoryTokenStorage()..refresh = '';
      final needsLogin = (await store.readRefresh() ?? '').isEmpty;
      expect(needsLogin, isTrue);
    });

    test('menyimpan dan membersihkan token', () async {
      final store = InMemoryTokenStorage();
      await store.save(access: 'a', refresh: 'r');
      expect(await store.readAccess(), 'a');
      await store.clear();
      expect(await store.readAccess(), isNull);
    });
  });

  group('api client refresh otomatis', () {
    test('401 memicu refresh sekali lalu retry sukses', () async {
      final store = InMemoryTokenStorage()
        ..access = 'expired'
        ..refresh = 'refresh-ok';
      final auth = FakeAuth();
      final dio = buildApiClient(store, auth);
      final adapter = FakeAdapter();
      dio.httpClientAdapter = adapter;

      final response = await dio.get('/pengumuman');

      expect(response.statusCode, 200);
      expect(auth.refreshCalls, 1);
      expect(adapter.calls, 2); // request awal + retry
      expect(adapter.seenAuth.first, 'Bearer expired');
      expect(adapter.seenAuth.last, 'Bearer renewed');
      expect(await store.readAccess(), 'renewed');
    });

    test('refresh gagal -> sesi dibersihkan', () async {
      final store = InMemoryTokenStorage()
        ..access = 'expired'
        ..refresh = 'refresh-mati';
      final auth = FakeAuth(failRefresh: true);
      final dio = buildApiClient(store, auth);
      dio.httpClientAdapter = FakeAdapter();

      await expectLater(dio.get('/pengumuman'), throwsA(isA<DioException>()));
      expect(await store.readAccess(), isNull);
      expect(await store.readRefresh(), isNull);
    });
  });
}
