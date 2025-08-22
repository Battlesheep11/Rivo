import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/profile/presentation/providers/auth_view_model_provider.dart';
import 'package:rivo_app_beta/core/analytics/analytics_service.dart'; // ← NEW

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    // Log screen view when entering profile screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.logScreenView(screenName: 'profile_screen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Log logout event
                AnalyticsService.logEvent('logout_clicked');

                // Perform sign out
                ref.read(authViewModelProvider.notifier).signOut();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
