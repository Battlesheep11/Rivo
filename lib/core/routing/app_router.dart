import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo_app/features/auth/presentation/auth_screen.dart';


class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthScreen(),  // ✅ This is the change!
      ),
    ],
  );
}
