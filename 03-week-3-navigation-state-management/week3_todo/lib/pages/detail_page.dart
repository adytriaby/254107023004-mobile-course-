import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/todo_provider.dart';

/// Halaman detail tugas yang dibuka lewat path parameter `/detail/:index`.
class DetailPage extends ConsumerWidget {
  const DetailPage({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final valid = index >= 0 && index < todos.length;

    return Scaffold(
      appBar: AppBar(title: Text('Detail Tugas #$index')),
      body: Center(
        child: !valid
            ? const Text('Tugas tidak ditemukan')
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      todos[index].done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 64,
                      color: todos[index].done ? Colors.green : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      todos[index].title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      todos[index].done
                          ? 'Status: Selesai'
                          : 'Status: Belum selesai',
                    ),
                    const SizedBox(height: 24),
                    FilledButton.tonal(
                      onPressed: () => context.go('/'),
                      child: const Text('Kembali ke daftar'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
