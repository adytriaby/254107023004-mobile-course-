import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/cached_posts_page.dart';
import 'pages/note_detail_page.dart';
import 'pages/notes_page.dart';
import 'pages/settings_page.dart';

final GoRouter router = GoRouter(
  initialLocation: const String.fromEnvironment(
    'INITIAL_LOCATION',
    defaultValue: '/',
  ),
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const NotesPage(),
              routes: [
                GoRoute(
                  path: 'note/:id',
                  builder: (context, state) => NoteDetailPage(
                    id: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cache',
              builder: (context, state) => const CachedPostsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sticky_note_2), label: 'Catatan'),
          NavigationDestination(icon: Icon(Icons.cloud_queue), label: 'Cache'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
    );
  }
}
