import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Satu item tugas.
class Todo {
  const Todo(this.title, {this.done = false});

  final String title;
  final bool done;

  Todo copyWith({String? title, bool? done}) =>
      Todo(title ?? this.title, done: done ?? this.done);
}

/// Status pengelola daftar tugas. State selalu diganti dengan list baru
/// (immutability) agar Riverpod mendeteksi perubahan dan UI ter-rebuild.
class TodoListNotifier extends Notifier<List<Todo>> {
  static const bool seed =
      bool.fromEnvironment('SEED_TODOS', defaultValue: false);

  @override
  List<Todo> build() => seed
      ? const [
          Todo('Belajar GoRouter'),
          Todo('Kerjakan tugas Riverpod', done: true),
          Todo('Baca dokumentasi AsyncValue'),
        ]
      : const [];

  void add(String title) => state = [...state, Todo(title)];

  void toggle(int index) {
    final todos = [...state];
    todos[index] = todos[index].copyWith(done: !todos[index].done);
    state = todos;
  }

  void remove(int index) => state = [...state]..removeAt(index);
}

final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

/// Filter tampilan daftar tugas.
enum TodoFilter { semua, aktif, selesai }

class TodoFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.semua;

  void set(TodoFilter filter) => state = filter;
}

final todoFilterProvider =
    NotifierProvider<TodoFilterNotifier, TodoFilter>(TodoFilterNotifier.new);

/// Provider turunan: membaca [todoListProvider] dan [todoFilterProvider]
/// lalu mengembalikan daftar yang sudah difilter.
final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);
  switch (filter) {
    case TodoFilter.semua:
      return todos;
    case TodoFilter.aktif:
      return todos.where((t) => !t.done).toList();
    case TodoFilter.selesai:
      return todos.where((t) => t.done).toList();
  }
});

/// Statistik ringkas untuk halaman Stats.
final todoStatsProvider = Provider<Map<String, int>>((ref) {
  final todos = ref.watch(todoListProvider);
  return {
    'total': todos.length,
    'selesai': todos.where((t) => t.done).length,
    'aktif': todos.where((t) => !t.done).length,
  };
});
