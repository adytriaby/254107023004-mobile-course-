import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/paged_post_page.dart';
import 'pages/post_detail_page.dart';
import 'pages/post_list_page.dart';

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
              builder: (context, state) => const PostListPage(),
              routes: [
                GoRoute(
                  path: 'post/:id',
                  builder: (context, state) => PostDetailPage(
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
              path: '/paged',
              builder: (context, state) => const PagedPostPage(),
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
          NavigationDestination(icon: Icon(Icons.list), label: 'Posts'),
          NavigationDestination(icon: Icon(Icons.all_inclusive), label: 'Paged'),
        ],
      ),
    );
  }
}
