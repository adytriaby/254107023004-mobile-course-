import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/network_errors.dart';
import '../data/providers.dart';

/// Halaman detail post `/post/:id` yang juga memuat komentar.
class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(id));
    final commentsAsync = ref.watch(postCommentsProvider(id));

    return Scaffold(
      appBar: AppBar(title: Text('Post #$id')),
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(friendlyErrorMessage(err), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(postDetailProvider(id)),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (post) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(post.title,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(post.body),
            const Divider(height: 32),
            Text('Komentar',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            commentsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Text(friendlyErrorMessage(err)),
              data: (comments) => Column(
                children: [
                  for (final c in comments)
                    Card(
                      elevation: 0,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(c.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        subtitle: Text(c.body,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
