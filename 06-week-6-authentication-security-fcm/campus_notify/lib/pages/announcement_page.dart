import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/announcement_provider.dart';
import '../routes.dart';

class AnnouncementPage extends ConsumerWidget {
  const AnnouncementPage({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(announcementProvider(id));

    return Scaffold(
      appBar: AppBar(title: Text('Pengumuman #$id')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (a) {
          if (a == null) {
            return const Center(child: Text('Pengumuman tidak ditemukan.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Chip(
                    avatar: const Icon(Icons.notifications, size: 18),
                    label: const Text('Dibuka dari notifikasi'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(a.title,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(a.date, style: Theme.of(context).textTheme.bodySmall),
              const Divider(height: 32),
              Text(a.body),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Kembali ke beranda'),
              ),
            ],
          );
        },
      ),
    );
  }
}
