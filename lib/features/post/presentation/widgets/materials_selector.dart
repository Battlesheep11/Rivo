import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/providers/lookup_provider.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';

class MaterialsSelector extends ConsumerWidget {
  final List<String> selectedCodes;
  final void Function(List<String>) onChanged;
  final String? otherMaterial;
  final void Function(String?)? onOtherChanged;

  const MaterialsSelector({
    super.key,
    required this.selectedCodes,
    required this.onChanged,
    this.otherMaterial,
    this.onOtherChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lookupAsync = ref.watch(lookupProvider);
    final t = AppLocalizations.of(context)!;

    return lookupAsync.when(
      data: (lookup) {
        final allMaterials = lookup.materials;
        final otherCode = 'other';
        final hasOther = selectedCodes.contains(otherCode);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.materials),
            Wrap(
              spacing: 8,
              children: allMaterials.map((item) {
                final isSelected = selectedCodes.contains(item.code);
                return FilterChip(
                  label: Text(item.code),
                  selected: isSelected,
                  onSelected: (selected) {
                    final updated = List<String>.from(selectedCodes);
                    selected
                        ? updated.add(item.code)
                        : updated.remove(item.code);
                    onChanged(updated);
                  },
                );
              }).toList()
              ..add(
                FilterChip(
                  label: Text(t.other),
                  selected: hasOther,
                  onSelected: (selected) {
                    final updated = List<String>.from(selectedCodes);
                    selected
                        ? updated.add(otherCode)
                        : updated.remove(otherCode);
                    onChanged(updated);
                  },
                ),
              ),
            ),
            if (hasOther && onOtherChanged != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  initialValue: otherMaterial,
                  onChanged: onOtherChanged,
                  decoration: InputDecoration(
                    labelText: t.otherMaterial,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (err, _) => Text(t.failedToLoad),
    );
  }
}
