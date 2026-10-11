import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../messaging/push_service.dart';
import '../providers/announcement_provider.dart';
import '../routes.dart';

/// Halaman Debug: menampilkan token terpotong (jangan pernah tampilkan penuh)
/// dan matriks pengujian tiga app state.
class DebugPage extends ConsumerWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final push = ref.watch(pushServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug FCM'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.vpn_key),
              title: const Text('FCM registration token'),
              subtitle: Text(push.displayToken),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.topic),
              title: const Text('Topik langganan'),
              subtitle: const Text('pengumuman-kampus'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(
                PushService.firebaseEnabled ? Icons.check_circle : Icons.info,
              ),
              title: const Text('Status Firebase'),
              subtitle: Text(
                PushService.firebaseEnabled
                    ? 'Aktif (FIREBASE_ENABLED=true)'
                    : 'Mode simulasi (Firebase belum dikonfigurasi)',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Matriks pengujian tiga app state',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const _TestMatrix(),
        ],
      ),
    );
  }
}

class _TestMatrix extends StatelessWidget {
  const _TestMatrix();

  static const _rows = [
    ('Foreground', 'Banner lokal muncul, klik ke /pengumuman/3'),
    ('Background', 'Banner sistem, klik ke rute yang benar'),
    ('Terminated', 'Terbuka ke rute via getInitialMessage'),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (final row in _rows)
            ListTile(
              dense: true,
              leading: const Icon(Icons.check, color: Colors.green),
              title: Text(row.$1),
              subtitle: Text(row.$2),
            ),
        ],
      ),
    );
  }
}
