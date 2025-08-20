import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/providers/lookup_provider.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';

class DefectsSelector extends ConsumerWidget {
  final List<String> selectedCodes;
  final String? otherNote;
  final void Function(List<String>) onChanged;
  final void Function(String?) onOtherChanged;

  const DefectsSelector({
    super.key,
    required this.selectedCodes,
    required this.otherNote,
    required this.onChanged,
    required this.onOtherChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lookup = ref.watch(lookupProvider);

    return lookup.when(
      data: (data) {
        final defects = data.defectTypes;
        final isOtherSelected = selectedCodes.contains('other');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.defects),
            Wrap(
              spacing: 8,
              children: defects.map((defect) {
                final isSelected = selectedCodes.contains(defect.code);
                return FilterChip(
                  label: Text(defect.code),
                  selected: isSelected,
                  onSelected: (selected) {
                    final updated = [...selectedCodes];
                    selected
                        ? updated.add(defect.code)
                        : updated.remove(defect.code);
                    onChanged(updated);
                  },
                );
              }).toList(),
            ),
            if (isOtherSelected) ...[
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.otherDefectNote,
                ),
                onChanged: onOtherChanged,
                controller: TextEditingController(text: otherNote),
              ),
            ],
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
error: (_, _) => Text(AppLocalizations.of(context)!.failedToLoad),
    );
  }
}
