import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:rivo_app_beta/features/post/domain/providers/category_providers.dart';
import 'package:rivo_app_beta/features/post/presentation/viewmodels/upload_post_viewmodel.dart';

class CategoryDropdown extends ConsumerWidget {
  const CategoryDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final viewModel = ref.read(uploadPostViewModelProvider.notifier);
    final state = ref.watch(uploadPostViewModelProvider);
    final t = AppLocalizations.of(context)!;

    return categoriesAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => Text(t.uploadUnexpectedError),
      data: (categories) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.category,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: state.categoryId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              hint: Text(t.selectCategory),
              items: categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  viewModel.setCategory(value);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.fieldRequired;
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }
}
