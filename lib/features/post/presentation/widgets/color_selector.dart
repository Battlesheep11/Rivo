import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/core/providers/lookup_provider.dart';
import 'package:rivo_app_beta/features/post/presentation/widgets/color_dot.dart';

class ColorSelector extends ConsumerWidget {
  final List<String> selectedCodes;
  final void Function(List<String>) onChanged;

  const ColorSelector({
    super.key,
    required this.selectedCodes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lookupAsync = ref.watch(lookupProvider);

    return lookupAsync.when(
      data: (lookup) {
        final colors = lookup.colors;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.color),
            Wrap(
              spacing: 8,
              children: colors.map((colorItem) {
                final isSelected = selectedCodes.contains(colorItem.code);
                return GestureDetector(
                  onTap: () {
                    final updated = [...selectedCodes];
                    if (isSelected) {
                      updated.remove(colorItem.code);
                    } else {
                      updated.add(colorItem.code);
                    }
                    onChanged(updated);
                  },
                  child: ColorDot(
                    hex: colorItem.hex,
                    isSelected: isSelected,
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text(AppLocalizations.of(context)!.failedToLoad),
    );
  }
}
