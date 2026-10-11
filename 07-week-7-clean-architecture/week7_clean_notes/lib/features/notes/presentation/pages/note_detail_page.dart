import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/format.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Catatan #$id')),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (notes) {
          final matches = notes.where((n) => n.id == id);
          if (matches.isEmpty) {
            return const Center(child: Text('Catatan tidak ditemukan.'));
          }
          return _Detail(note: matches.first);
        },
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.note});
  final Note note;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(note.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              note.dirty ? Icons.cloud_upload : Icons.cloud_done,
              size: 18,
              color: note.dirty
                  ? Theme.of(context).colorScheme.error
                  : Colors.green,
            ),
            const SizedBox(width: 6),
            Text(note.dirty ? 'Belum tersinkron' : 'Tersinkron'),
            const Spacer(),
            Text(formatDate(note.updatedAt)),
          ],
        ),
        const Divider(height: 32),
        Text(note.body.isEmpty ? 'Tanpa isi' : note.body),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => context.go('/'),
          child: const Text('Kembali ke daftar'),
        ),
      ],
    );
  }
}
