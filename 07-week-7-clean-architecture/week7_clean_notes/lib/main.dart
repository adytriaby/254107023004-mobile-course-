import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'features/auth/presentation/providers/auth_providers.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
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
    const autoLogin = bool.fromEnvironment('AUTO_LOGIN', defaultValue: false);
    if (autoLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(authProvider.notifier)
            .login('mahasiswa@polinema.ac.id', 'polinema123');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Week 7 - Clean Architecture',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
    );
  }
}
