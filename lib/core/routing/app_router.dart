import 'package:flutter/material.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/auth_repository_provider.dart';

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
import 'package:rivo_app_beta/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:rivo_app_beta/features/auth/presentation/screens/reset_password_screen.dart';


class AppRouter {
  static GoRouter createRouter(WidgetRef ref) {
    final authState = ref.watch(authSessionProvider);
    final isLoggedIn = authState.asData?.value != null;
    final authRepository = ref.read(authRepositoryProvider);

    return GoRouter(
      initialLocation: '/redirect',
      redirect: (context, state) async {
        // Handle password recovery deep link - this must be checked first
        if (state.uri.fragment.contains('type=recovery')) {
          final params = Uri.splitQueryString(state.uri.fragment);
          final accessToken = params['access_token'];
          if (accessToken != null) {
            // Force sign out to clear any existing session created by Supabase
            try {
              await authRepository.signOut();
              // Add a small delay to ensure the session is cleared
              await Future.delayed(const Duration(milliseconds: 100));
            } catch (e) {
              // Ignore sign out errors - user might not be signed in
            }
            // Navigate to reset password with the token
            return '/reset-password?token=$accessToken';
          }
        }

        // Check if we're on a password reset URL with a token (backup check)
        if (state.uri.queryParameters.containsKey('token') && 
            state.matchedLocation.startsWith('/reset-password')) {
          // Force sign out if somehow still authenticated
          if (isLoggedIn) {
            try {
              await authRepository.signOut();
              await Future.delayed(const Duration(milliseconds: 100));
            } catch (e) {
              // Ignore sign out errors
            }
          }
          return null; // Allow access to reset password screen
        }

        // Allow access to reset-password route regardless of auth state
        if (state.matchedLocation.startsWith('/reset-password')) {
          return null;
        }

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
           routes: [
             GoRoute(
               path: 'forgot-password',
               pageBuilder: (context, state) => MaterialPage(child: ForgotPasswordScreen()),
             ),
           ],
         ),
        GoRoute(
          path: '/reset-password',
          builder: (context, state) {
            final token = state.uri.queryParameters['token'];
            if (token == null || token.isEmpty) {
              // If no token is provided, redirect to auth screen
              return const AuthScreen();
            }
            return ResetPasswordScreen(token: token);
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
