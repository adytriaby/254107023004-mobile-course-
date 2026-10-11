import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({super.key});

  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends ConsumerState<TodoPage> {
  static const bool autoDialog =
      bool.fromEnvironment('AUTO_DIALOG', defaultValue: false);

  @override
  void initState() {
    super.initState();
    if (autoDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showAddDialog();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(filteredTodosProvider);
    final filter = ref.watch(todoFilterProvider);
    final stats = ref.watch(todoStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ToDo Riverpod')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<TodoFilter>(
              segments: const [
                ButtonSegment(value: TodoFilter.semua, label: Text('Semua')),
                ButtonSegment(value: TodoFilter.aktif, label: Text('Aktif')),
                ButtonSegment(
                    value: TodoFilter.selesai, label: Text('Selesai')),
              ],
              selected: {filter},
              onSelectionChanged: (value) =>
                  ref.read(todoFilterProvider.notifier).set(value.first),
            ),
          ),
          Expanded(
            child: todos.isEmpty
                ? const Center(child: Text('Belum ada tugas'))
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      final realIndex =
                          ref.read(todoListProvider).indexOf(todo);
                      return TodoTile(
                        todo: todo,
                        onToggle: () => ref
                            .read(todoListProvider.notifier)
                            .toggle(realIndex),
                        onDelete: () => ref
                            .read(todoListProvider.notifier)
                            .remove(realIndex),
                        onTap: () => context.go('/detail/$realIndex'),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Total: ${stats['total']}  ·  '
              'Aktif: ${stats['aktif']}  ·  Selesai: ${stats['selesai']}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama tugas'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(todoListProvider.notifier)
                    .add(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
