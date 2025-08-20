import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/providers/lookup_provider.dart';
import 'package:rivo_app_beta/features/post/presentation/viewmodels/upload_post_viewmodel.dart';

class StatusDropdown extends ConsumerWidget {
  const StatusDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lookupAsync = ref.watch(lookupProvider);
    final viewModel = ref.read(uploadPostViewModelProvider.notifier);
    final state = ref.watch(uploadPostViewModelProvider);

    return lookupAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
      data: (lookup) {
        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Status'),
          initialValue: state.statusCode.isNotEmpty ? state.statusCode : null,
          items: lookup.statuses
              .map((item) => DropdownMenuItem<String>(
                    value: item.code,
                    child: Text(item.code),
                  ))
              .toList(),
          onChanged: (code) {
            if (code != null) {
              viewModel.setStatusCode(code);
            }
          },
        );
      },
    );
  }
}
