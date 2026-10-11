import 'package:dio/dio.dart';

/// `BAD_BASE_URL=true` (dart-define) mengarahkan ke URL salah untuk
/// mendemonstrasikan state error secara deterministik.
const bool kBadBaseUrl =
    bool.fromEnvironment('BAD_BASE_URL', defaultValue: false);

/// Membuat klien Dio terpusat (base URL, timeout, logging).
Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: kBadBaseUrl
          ? 'https://invalid.example.invalid'
          : 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(
    LogInterceptor(requestBody: true, responseBody: false),
  );
  return dio;
}
