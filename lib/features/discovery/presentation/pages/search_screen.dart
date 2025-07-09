import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app/core/localization/generated/app_localizations.dart';
import 'package:rivo_app/features/discovery/presentation/providers/search_query_provider.dart';
import 'package:rivo_app/features/discovery/presentation/widgets/product_results_tab.dart';
import 'package:rivo_app/features/discovery/presentation/widgets/discover_top_section.dart'; // ודאי שקיים
import 'package:rivo_app/features/discovery/presentation/widgets/user_results_tab.dart';
import 'package:rivo_app/features/discovery/presentation/widgets/tag_results_tab.dart';

class SearchScreen extends HookConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();
    final focusNode = useFocusNode();
    final hasSubmitted = useState(false);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.searchTitle),
        ),
        body: Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(
            children: [
              TextField(
                controller: textController,
                focusNode: focusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  final trimmed = value.trim();
                  ref.read(searchQueryProvider.notifier).state = trimmed;
                  hasSubmitted.value = trimmed.isNotEmpty;
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  fillColor: Colors.white.withAlpha((0.1 * 255).toInt()),
                  filled: true,
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 12),

              // הצג תוצאות רק אחרי חיפוש
              Expanded(
                child: hasSubmitted.value
                    ? Column(
                        children: [
                          TabBar(
                            isScrollable: false,
                            tabs: [
                              Tab(text: AppLocalizations.of(context)!.tabProducts),
                              Tab(text: AppLocalizations.of(context)!.tabUsers),
                              Tab(text: AppLocalizations.of(context)!.tabTags),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Expanded(
                            child: TabBarView(
                              children: [
                                ProductResultsTab(),
                                UserResultsTab(),
                                TagResultsTab(),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const DiscoverTopSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
