import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:rivo_app/core/widgets/app_nav_bar.dart';
import 'package:rivo_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:rivo_app/features/feed/presentation/screens/feed_screen.dart';

class AppRouter {
  static GoRouter createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/auth', // ← מתחילים במסך ה־Auth
      routes: [
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            final location = state.uri.path;
            int index = _calculateIndex(location);

            return Scaffold(
              body: child,
              bottomNavigationBar: AppNavBar(
                currentIndex: index,
                onTap: (selectedIndex) {
                  final path = _getPath(selectedIndex);
                  if (path != location) {
                    context.go(path);
                  }
                },
              ),
            );
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const FeedScreen(),
            ),
            GoRoute(
              path: '/search',
              builder: (context, state) => const PlaceholderScreen(title: 'Search'),
            ),
            GoRoute(
              path: '/saved',
              builder: (context, state) => const PlaceholderScreen(title: 'Saved'),
            ),
            GoRoute(
              path: '/cart',
              builder: (context, state) => const PlaceholderScreen(title: 'Cart'),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const PlaceholderScreen(title: 'Profile'),
            ),
          ],
        ),
      ],
    );
  }

  static int _calculateIndex(String location) {
    switch (location) {
      case '/home':
        return 0;
      case '/search':
        return 1;
      case '/saved':
        return 2;
      case '/cart':
        return 3;
      case '/profile':
        return 4;
      default:
        return 0;
    }
  }

  static String _getPath(int index) {
    switch (index) {
      case 0:
        return '/home';
      case 1:
        return '/search';
      case 2:
        return '/saved';
      case 3:
        return '/cart';
      case 4:
        return '/profile';
      default:
        return '/home';
    }
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$title Screen'));
  }
}
