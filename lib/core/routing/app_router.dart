import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rivo_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:rivo_app/features/auth/presentation/screens/auth_redirector_screen.dart';
import 'package:rivo_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:rivo_app/features/post/presentation/screens/post_upload_screen.dart';
import 'package:rivo_app/features/feed/presentation/screens/feed_screen.dart';
import 'package:rivo_app/core/widgets/app_nav_bar.dart';
import 'package:rivo_app/features/discovery/presentation/screens/discovery_screen.dart';
import 'package:rivo_app/features/discovery/presentation/pages/search_screen.dart';


class AppRouter {
  static GoRouter createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/auth', 
      routes: [
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: '/redirect', 
          builder: (context, state) => const AuthRedirectorScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/upload',
          builder: (context, state) => const PostUploadScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            final location = state.uri.path;
            final index = _calculateIndex(location);

            return Scaffold(
              body: child,
              bottomNavigationBar: AppNavBar(
                currentIndex: index,
                onTap: (selectedIndex) {
                  final target = _getPath(selectedIndex);
                  if (target != location) context.go(target);
                },
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              floatingActionButton: FutureBuilder<bool>(
                future: _isSeller(),
                builder: (context, snapshot) {
                  final isSeller = snapshot.data ?? false;
                  if (!isSeller) return const SizedBox.shrink();
                  return FloatingActionButton(
                    onPressed: () => context.go('/upload'),
                    child: const Icon(Icons.add),
                  );
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
              path: '/discovery',
              builder: (context, state) => const DiscoveryScreen(),
            ),
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
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
      case '/discovery':
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
        return '/discovery';
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

  static Future<bool> _isSeller() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    final profile = await Supabase.instance.client
        .from('profiles')
        .select('is_seller')
        .eq('id', user.id)
        .maybeSingle();

    return profile != null && profile['is_seller'] == true;
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('$title Screen')),
    );
  }
}
