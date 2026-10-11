import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'messaging/push_service.dart';
import 'providers/announcement_provider.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase hanya diinisialisasi bila dikonfigurasi (google-services.json /
  // firebase_options.dart tersedia). Tanpa itu, aplikasi berjalan dalam mode
  // simulasi sehingga tetap dapat dijalankan dan diuji.
  if (PushService.firebaseEnabled) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    if (!PushService.firebaseEnabled) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final router = ref.read(routerProvider);
      await ref.read(pushServiceProvider).init(
            onToken: (token) async {
              // Kirim ke backend: POST /devices
              debugPrint('[FCM] token terkirim ke backend: '
                  '${token.substring(0, 12)}...');
            },
            go: (route) => router.go(route),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Campus Notification',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    );
  }
}
