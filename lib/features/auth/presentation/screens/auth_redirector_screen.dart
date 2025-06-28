import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRedirectorScreen extends ConsumerStatefulWidget {
  const AuthRedirectorScreen({super.key});

  @override
  ConsumerState<AuthRedirectorScreen> createState() => _AuthRedirectorScreenState();
}

class _AuthRedirectorScreenState extends ConsumerState<AuthRedirectorScreen> {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() async {
        await _handleRedirect();
      });
    });
  }

  Future<void> _handleRedirect() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      if (mounted) context.go('/auth');
      return;
    }

    final userTagRows = await Supabase.instance.client
        .from('user_tags')
        .select('tag_id')
        .eq('user_id', user.id);

    final hasTags = userTagRows.isNotEmpty;

    if (!mounted) return;

    if (hasTags) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
