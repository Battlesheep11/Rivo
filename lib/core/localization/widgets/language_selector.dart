import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../locale_provider.dart';
import '../supported_locales.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final direction = Directionality.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          value: locale,
          icon: const Padding(
            padding: EdgeInsets.only(left: 8.0, right: 4),
            child: Icon(Icons.language, size: 20),
          ),
          alignment: direction == TextDirection.rtl
              ? AlignmentDirectional.topStart
              : AlignmentDirectional.topEnd,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          onChanged: (Locale? newLocale) {
            if (newLocale != null) {
              ref.read(localeProvider.notifier).setLocale(newLocale);
            }
          },
          items: SupportedLocales.locales.map((localeItem) {
            final isSelected = localeItem.languageCode == locale.languageCode;
            return DropdownMenuItem(
              value: localeItem,
              child: Text(
                SupportedLocales.getLanguageName(localeItem),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
