import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkAsync = ref.watch(darkModeProvider);
    final lastOpenedAsync = ref.watch(lastOpenedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          darkAsync.when(
            loading: () => const ListTile(
              title: Text('Tema gelap'),
              trailing: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, _) => ListTile(
              title: const Text('Tema gelap'),
              subtitle: Text('Gagal membaca preferensi: $e'),
            ),
            data: (isDark) => SwitchListTile(
              title: const Text('Tema gelap'),
              subtitle: const Text('Disimpan dengan SharedPreferences'),
              value: isDark,
              onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
            ),
          ),
          const Divider(),
          lastOpenedAsync.when(
            loading: () => const ListTile(
              leading: Icon(Icons.history),
              title: Text('Terakhir dibuka'),
              subtitle: Text('Memuat...'),
            ),
            error: (e, _) => const ListTile(
              leading: Icon(Icons.history),
              title: Text('Terakhir dibuka'),
              subtitle: Text('Tidak tersedia'),
            ),
            data: (value) => ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Terakhir dibuka'),
              subtitle: Text(value ?? '-'),
            ),
          ),
        ],
      ),
    );
  }
}
