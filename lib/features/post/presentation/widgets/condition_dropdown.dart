import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/providers/lookup_provider.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/product/domain/utils/item_condition_label.dart';

class ConditionDropdown extends ConsumerWidget {
  final String? selectedCode;
  final void Function(String?) onChanged;

  const ConditionDropdown({
  super.key,
  required this.selectedCode,
  required this.onChanged,
});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lookupAsync = ref.watch(lookupProvider);

    return lookupAsync.when(
      data: (lookup) {
        final conditions = lookup.conditions;
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: l10n.conditionLabel,
            hintText: l10n.selectConditionHint,
            prefixIcon: const Icon(Icons.check_circle_outline),
          ),
          initialValue: selectedCode,
          items: conditions.map((item) {
            return DropdownMenuItem<String>(
              value: item.code,
              child: Text(itemConditionLabel(context, item.code)),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.conditionRequired;
            }
            return null;
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (err, _) => Text('Error: $err'),
    );
  }
}
