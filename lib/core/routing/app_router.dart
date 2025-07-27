import 'package:flutter/material.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rivo_app_beta/features/auth/presentation/screens/auth_screen.dart';
import 'package:rivo_app_beta/features/auth/presentation/screens/auth_redirector_screen.dart';
import 'package:rivo_app_beta/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:rivo_app_beta/features/post/presentation/screens/post_upload_screen.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:rivo_app_beta/features/feed/presentation/screens/feed_screen.dart';
import 'package:rivo_app_beta/features/profile/presentation/views/profile_page.dart';
import 'package:rivo_app_beta/features/profile/presentation/widgets/settings_screen.dart';
import 'package:rivo_app_beta/core/widgets/app_nav_bar.dart';



class AppRouter {
  static GoRouter createRouter(WidgetRef ref) {
    final authState = ref.watch(authSessionProvider);

    return GoRouter(
      initialLocation: '/redirect',
      redirect: (context, state) {
        // If the user is not logged in, they are redirected to the /auth screen
        final loggedIn = authState.asData?.value != null;
        final loggingIn = state.matchedLocation == '/auth';

        if (!loggedIn) {
          return '/auth';
        }

        // if the user is logged in but still on the login page, send them to
        // the home page
        if (loggingIn) {
          return '/home';
        }

        return null;
      },
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
        // Settings route
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            final location = state.uri.path;
            final index = _calculateIndex(location);

            return Scaffold(
              body: Stack(
                children: [
                  child,
                  AppNavBar(
                    currentIndex: index,
                    onTap: (selectedIndex) {
                      final target = _getPath(selectedIndex);
                      if (target != location) context.go(target);
                    },
                  ),
                ],
              ),
              // Use centerFloat to place FAB above the floating nav bar
              floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
              floatingActionButton: FutureBuilder<bool>(
                future: _isSeller(),
                builder: (context, snapshot) {
                  final isSeller = snapshot.data ?? false;
                  if (!isSeller) return const SizedBox.shrink();
                  // FAB floats above nav bar with extra bottom padding for visual harmony
                  return Padding(
                    padding: const EdgeInsets.only(left: 300.0, bottom: 16.0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go('/upload'),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(26),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.black87,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
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
              path: '/search',
              builder: (context, state) => PlaceholderScreen(title: AppLocalizations.of(context)!.navBarSearch),
            ),


                                    GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
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

      case '/profile':
        return 2;
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
      body: Center(child: Text(AppLocalizations.of(context)!.placeholderScreenTitle(title))),
    );
  }
}
