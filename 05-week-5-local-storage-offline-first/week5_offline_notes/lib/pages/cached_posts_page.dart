import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

/// Cache-first read: tampilkan cache lokal seketika, refresh dari jaringan
/// di background dan simpan hasilnya untuk kunjungan berikutnya.
class CachedPostsPage extends ConsumerWidget {
  const CachedPostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cachedAsync = ref.watch(cachedPostsProvider);
    final lastCachedAsync = ref.watch(lastCachedAtProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cached Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download),
            tooltip: 'Refresh dari jaringan',
            onPressed: () => _refreshFromNetwork(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          lastCachedAsync.maybeWhen(
            data: (dt) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                dt == null
                    ? 'Cache kosong. Tekan tombol cloud untuk memuat dari jaringan.'
                    : 'Cache terakhir: ${dt.toLocal()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          Expanded(
            child: cachedAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal membaca cache: $e')),
              data: (rows) {
                if (rows.isEmpty) {
                  return const Center(
                    child: Text('Belum ada cache. Muat dari jaringan.'),
                  );
                }
                return ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${row['id']}')),
                      title: Text(
                        '${row['payload'] ?? row['title'] ?? ''}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshFromNetwork(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final dio = ref.read(dioProvider);
      final cache = ref.read(postCacheRepositoryProvider);
      final response = await dio.get<List>('/posts');
      final now = DateTime.now().toIso8601String();
      final payload = (response.data ?? [])
          .whereType<Map<String, dynamic>>()
          .map((p) => {
                'id': (p['id'] as num?)?.toInt() ?? 0,
                'payload': p.toString(),
                'cached_at': now,
              })
          .toList();
      await cache.saveCachedPosts(payload);
      ref.invalidate(cachedPostsProvider);
      ref.invalidate(lastCachedAtProvider);
      messenger.showSnackBar(
        SnackBar(content: Text('Cache diperbarui: ${payload.length} post')),
      );
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Gagal refresh. Cache lama tetap ditampilkan (offline-first).'),
        ),
      );
    }
  }
}
