import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app/core/localization/generated/app_localizations.dart';
import 'package:rivo_app/features/discovery/domain/usecases/search_sellers_use_case.dart';
import 'package:rivo_app/features/discovery/presentation/providers/search_query_provider.dart';
import 'package:rivo_app/features/discovery/presentation/widgets/user_result_card.dart';

class UserResultsTab extends ConsumerWidget {
  const UserResultsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchSellersUseCaseProvider(query));

    return resultsAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noMatchingSellers),
          );
        }

        return Directionality(
  textDirection: TextDirection.ltr,
  child: ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: users.length,
    separatorBuilder: (context, index) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      return UserResultCard(seller: users[index]);
    },
  ),
);

      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('${AppLocalizations.of(context)!.errorOccurred} $e'),
      ),
    );
  }
}
