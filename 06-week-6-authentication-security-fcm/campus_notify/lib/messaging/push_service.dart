import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../routes.dart';

/// Handler background WAJIB top-level (berjalan di isolate terpisah).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Jangan akses BuildContext / Riverpod di sini.
  // Tugasnya hanya mencatat / menyimpan ringan. Navigasi dilakukan saat klik.
  debugPrint('[FCM background] ${message.messageId} '
      '${message.data}');
}

/// Rute yang tertunda dari klik notifikasi (foreground/terminated).
String? pendingDeepLink;

class PushService {
  PushService({FirebaseMessaging? messaging, FlutterLocalNotificationsPlugin? local})
      : _messagingOverride = messaging,
        _local = local ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging? _messagingOverride;
  final FlutterLocalNotificationsPlugin _local;

  /// Akses FirebaseMessaging hanya saat benar-benar dipakai, agar aplikasi
  /// tetap berjalan (mode simulasi) tanpa konfigurasi Firebase.
  FirebaseMessaging get _messaging =>
      _messagingOverride ?? FirebaseMessaging.instance;

  /// Token terakhir yang berhasil diambil (ditampilkan terpotong di Debug).
  String? lastToken;

  /// `FIREBASE_ENABLED=true` (dart-define) mengaktifkan jalur Firebase nyata.
  static const bool firebaseEnabled =
      bool.fromEnvironment('FIREBASE_ENABLED', defaultValue: false);

  static const _topic = 'pengumuman-kampus';

  /// Inisialisasi lengkap: izin, token lifecycle, handler 3 state, topik.
  Future<void> init({
    required Future<void> Function(String token) onToken,
    required void Function(String route) go,
  }) async {
    await requestNotificationPermission();
    await initLocalNotifications();
    await initFcmToken(onToken: onToken);
    listenForeground(go);
    await handleTerminated(go);
  }

  /// Meminta izin notifikasi (wajib Android 13+ dan iOS).
  Future<bool> requestNotificationPermission() async {
    if (!firebaseEnabled) return false;
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> initLocalNotifications() async {
    if (kIsWeb) return; // flutter_local_notifications tidak dipakai di web.
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        pendingDeepLink = response.payload;
      },
    );
  }

  /// Token lifecycle: ambil token, kirim ke backend, dan pantau perubahan.
  Future<void> initFcmToken({
    required Future<void> Function(String token) onToken,
  }) async {
    if (!firebaseEnabled) return;
    final token = await _messaging.getToken();
    if (token != null) {
      lastToken = token;
      await onToken(token);
    }
    // Token bisa berubah (reinstall, clear data, rotasi keamanan).
    // Listener ini WAJIB ada agar backend tidak menyimpan token basi.
    _messaging.onTokenRefresh.listen((token) async {
      lastToken = token;
      await onToken(token);
    });
    await _messaging.subscribeToTopic(_topic);
  }

  /// Foreground: sistem TIDAK menampilkan banner otomatis, tampilkan manual.
  void listenForeground(void Function(String route) go) {
    if (!firebaseEnabled) return;
    FirebaseMessaging.onMessage.listen((message) async {
      final route = routeFromMessage(message.data);
      if (!kIsWeb) {
        const androidDetails = AndroidNotificationDetails(
          'pengumuman',
          'Pengumuman Kampus',
          importance: Importance.high,
          priority: Priority.high,
        );
        await _local.show(
          id: message.hashCode,
          title: message.notification?.title ?? 'Pengumuman',
          body: message.notification?.body ?? '',
          notificationDetails: const NotificationDetails(android: androidDetails),
          payload: route,
        );
      } else {
        pendingDeepLink = route;
      }
    });

    // Background -> diklik.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      go(routeFromMessage(message.data));
    });
  }

  /// Terminated -> dibuka dari notifikasi via getInitialMessage.
  Future<void> handleTerminated(void Function(String route) go) async {
    if (!firebaseEnabled) return;
    final initial = await _messaging.getInitialMessage();
    if (initial != null) go(routeFromMessage(initial.data));
    if (pendingDeepLink != null) go(pendingDeepLink!);
  }

  Future<void> subscribeTopic(String topic) async {
    if (!firebaseEnabled) return;
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeTopic(String topic) async {
    if (!firebaseEnabled) return;
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Mode simulasi (tanpa Firebase) untuk demo/deep link di web:
  /// meniru pesan `notification + data` yang datang saat foreground.
  void simulateForegroundMessage({
    required String title,
    required String body,
    required String route,
    required void Function(String route) go,
  }) {
    pendingDeepLink = route;
    go(route);
  }

  /// Token contoh untuk halaman Debug bila Firebase belum dikonfigurasi.
  String get displayToken {
    final token = lastToken ?? 'simulasi-token-fcm-254107023004';
    return token.length <= 12 ? token : '${token.substring(0, 12)}...';
  }
}
