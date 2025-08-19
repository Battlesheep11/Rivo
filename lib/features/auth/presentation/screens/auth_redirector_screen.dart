import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


import 'package:rivo_app_beta/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/user_tags_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/core/toast/toast_service.dart';

class AuthRedirectorScreen extends ConsumerStatefulWidget {
  const AuthRedirectorScreen({super.key});

  @override
  ConsumerState<AuthRedirectorScreen> createState() => _AuthRedirectorScreenState();
}

class _AuthRedirectorScreenState extends ConsumerState<AuthRedirectorScreen> {
  bool _connectivityToastShown = false;

  @override
  void initState() {
    super.initState();
    // One-time connectivity check on app entry
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _connectivityToastShown) return;
      final results = await Connectivity().checkConnectivity();
      final isOffline = results.every((r) => r == ConnectivityResult.none);
      if (isOffline && mounted) {
        final l10n = AppLocalizations.of(context)!;
        ToastService().showError(l10n.noInternetConnection);
      }
      if (mounted) {
        setState(() => _connectivityToastShown = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authSessionProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/auth');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasTagsProvider = ref.watch(userHasTagsProvider);
        return hasTagsProvider.when(
          data: (hasTags) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (hasTags) {
                context.go('/home');
              } else {
                context.go('/onboarding');
              }
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => const Scaffold(
            body: Center(child: Text('Error checking user tags')),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go('/auth');
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
