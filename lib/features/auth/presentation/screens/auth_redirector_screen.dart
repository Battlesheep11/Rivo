import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


import 'package:rivo_app_beta/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/user_tags_provider.dart';

class AuthRedirectorScreen extends ConsumerWidget {
  const AuthRedirectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authSessionProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            context.go('/auth');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasTagsProvider = ref.watch(userHasTagsProvider);
        return hasTagsProvider.when(
          data: (hasTags) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
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
          context.go('/auth');
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
