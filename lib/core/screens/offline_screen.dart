import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/core/connectivity/connectivity_provider.dart';

/// A blocking screen shown when the device is offline.
/// Users cannot dismiss this screen until connectivity is restored.
class OfflineScreen extends ConsumerWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation while offline
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noInternetConnection,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Trigger a manual connectivity re-check
                        await ref.read(connectivityStatusProvider.notifier).retryCheck();
                        // If online, router's redirect will take over due to refreshListenable
                      },
                      child: Text(l10n.retry),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
