import 'package:flutter/material.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:rivo_app_beta/features/auth/presentation/screens/auth_screen.dart';
import 'package:rivo_app_beta/features/auth/presentation/screens/auth_redirector_screen.dart';
import 'package:rivo_app_beta/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:rivo_app_beta/features/post/presentation/screens/post_upload_screen_refactored.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:rivo_app_beta/features/feed/presentation/screens/feed_screen.dart';
import 'package:rivo_app_beta/features/profile/presentation/views/profile_page.dart';
import 'package:rivo_app_beta/features/profile/presentation/widgets/settings_screen.dart';
import 'package:rivo_app_beta/core/widgets/app_nav_bar.dart';
import 'package:rivo_app_beta/features/discovery/presentation/screens/discovery_screen.dart';
import 'package:rivo_app_beta/features/product/presentation/screens/product_screen.dart';
import 'package:rivo_app_beta/features/feed/presentation/screens/filtered_feed_screen.dart';


class AppRouter {
  static GoRouter createRouter(WidgetRef ref) {
    final authState = ref.watch(authSessionProvider);
    final isLoggedIn = authState.asData?.value != null;
    // Note: authRepository no longer needed after removing reset/forgot flows

    return GoRouter(
      initialLocation: '/redirect',
      redirect: (context, state) async {

        final isAuthRoute = state.matchedLocation.startsWith('/auth');

        // If user is not logged in and not on an auth-related page, redirect to /auth
        if (!isLoggedIn && !isAuthRoute) {
          return '/auth';
        }

        // If user is logged in but on an auth-related page, redirect to /home
        if (isLoggedIn && isAuthRoute) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
           path: '/auth',
           pageBuilder: (context, state) => MaterialPage(child: AuthScreen()),
         ),
        GoRoute(
          path: '/collection/:collectionId',
          builder: (context, state) {
            final id = state.pathParameters['collectionId']!;
            return FilteredFeedScreen(collectionId: id);
          },
        ),
        GoRoute(
          path: '/tag/:tagId',
          builder: (context, state) {
            final tagId = state.pathParameters['tagId']!;
            return FilteredFeedScreen(tagId: tagId);
          },
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
          builder: (context, state) => const PostUploadScreenRefactored(),
        ),
        // Settings route
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/product/:productId',
          builder: (context, state) {
            final productId = state.pathParameters['productId']!;
            return ProductScreen(productId: productId);
          },
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
              
            );
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const FeedScreen(),
            ),
            GoRoute(
              path: '/search',
              builder: (context, state) => const DiscoveryScreen(),
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
