import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/announcement_provider.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(announcementRepositoryProvider);
    final announcements = repo.all();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman Kampus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug token',
            onPressed: () => context.go(AppRoutes.debug),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adytria Bayu Ramadani',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Text('NIM 254107023004'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Pengumuman',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          for (final a in announcements)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.campaign),
                title: Text(a.title),
                subtitle: Text(a.date),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(AppRoutes.announcement(a.id)),
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.notifications_active),
              label: const Text('Simulasi notifikasi → /pengumuman/3'),
              onPressed: () => ref
                  .read(pushServiceProvider)
                  .simulateForegroundMessage(
                    title: 'Jadwal kuliah berubah',
                    body: 'Kelas Mobile pindah ke Ruang A2 jam 13.00',
                    route: AppRoutes.announcement('3'),
                    go: (route) => context.go(route),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
