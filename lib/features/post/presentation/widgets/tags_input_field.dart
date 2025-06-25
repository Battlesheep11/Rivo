import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app/core/localization/generated/app_localizations.dart';
import 'package:rivo_app/features/post/presentation/viewmodels/upload_post_viewmodel.dart';

class TagsInputField extends ConsumerStatefulWidget {
  const TagsInputField({super.key});

  @override
  ConsumerState<TagsInputField> createState() => _TagsInputFieldState();
}

class _TagsInputFieldState extends ConsumerState<TagsInputField> {
  final TextEditingController _controller = TextEditingController();
  List<TagItem> _suggestions = [];
  bool _showSuggestions = false;

  Future<List<TagItem>> fetchTags(String query) async {
    if (query.isEmpty) return [];

    final response = await Supabase.instance.client
        .from('tags')
        .select('id, name, is_visible')
        .ilike('name', '%$query%')
        .eq('is_visible', true);

    return (response as List<dynamic>)
        .map((item) => TagItem(id: item['id'], name: item['name']))
        .toList();
  }

  Future<TagItem> createTag(String name) async {
    final response = await Supabase.instance.client
        .from('tags')
        .insert({'name': name, 'is_visible': true})
        .select('id, name')
        .single();

    return TagItem(id: response['id'], name: response['name']);
  }

  void _onAddTag(TagItem tag) {
    final selected = ref.read(uploadPostViewModelProvider).tagNames;
    if (selected.contains(tag.name)) return;

    ref.read(uploadPostViewModelProvider.notifier).setTags([...selected, tag.name]);
    _controller.clear();
    _hideSuggestions();
  }

  void _onAddNewTag(String input) async {
    final existing = _suggestions.firstWhere(
      (t) => t.name.toLowerCase() == input.toLowerCase(),
      orElse: () => TagItem(id: '', name: ''),
    );

    if (existing.id.isNotEmpty) {
      _onAddTag(existing);
    } else {
      final created = await createTag(input.trim());
      _onAddTag(created);
    }
  }

  void _hideSuggestions() {
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadPostViewModelProvider);
    final selectedIds = state.tagNames;
    final localizations = AppLocalizations.of(context)!;

    final selectedTags = _suggestions.where((tag) => selectedIds.contains(tag.name)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.tags, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedTags.map((tag) {
            return InputChip(
              label: Text(tag.name),
              onDeleted: () {
                final updated = List<String>.from(selectedIds)..remove(tag.name);
                ref.read(uploadPostViewModelProvider.notifier).setTags(updated);
                setState(() {});
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            TextField(
              controller: _controller,
              onChanged: (value) async {
                final results = await fetchTags(value);
                setState(() {
                  _suggestions = results;
                  _showSuggestions = results.isNotEmpty;
                });
              },
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) _onAddNewTag(value.trim());
              },
              decoration: InputDecoration(
                labelText: localizations.tags,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final value = _controller.text.trim();
                    if (value.isNotEmpty) {
                      _onAddNewTag(value);
                    }
                  },
                ),
              ),
            ),
            if (_showSuggestions)
              Positioned(
                left: 0,
                right: 0,
                top: 60,
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(8),
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(0),
                    children: _suggestions.map((tag) {
                      return ListTile(
                        title: Text(tag.name),
                        onTap: () => _onAddTag(tag),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class TagItem {
  final String id;
  final String name;

  TagItem({required this.id, required this.name});
}
