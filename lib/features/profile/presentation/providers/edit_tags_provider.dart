import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/onboarding/domain/repositories/tag_repository_provider.dart';
import 'package:rivo_app_beta/features/profile/data/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

// Provider for fetching all available tags from Supabase
final allTagsProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(tagRepositoryProvider).getAllVisibleTags();
});

// Provider for managing the user's selected tags during editing
class EditTagsNotifier extends StateNotifier<AsyncValue<List<String>>> {
  EditTagsNotifier() : super(const AsyncValue.loading()) {
    _loadUserTags();
  }

  final ProfileService _profileService = ProfileService();

  Future<void> _loadUserTags() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final userTags = await _profileService.getTagsForUser(userId);
      state = AsyncData(userTags);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  void selectTag(String tag) {
    final currentTags = state.valueOrNull ?? [];
    if (currentTags.contains(tag)) {
      // Remove tag if already selected
      state = AsyncData([...currentTags]..remove(tag));
    } else {
      // Add tag if not selected
      state = AsyncData([...currentTags, tag]);
    }
  }

  Future<void> saveTags() async {
    final currentTags = state.valueOrNull ?? [];
    final previousState = state;
    state = const AsyncValue.loading();
    
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }
      
      // Convert tags to lowercase to avoid case-sensitivity issues
      final normalizedTags = currentTags.map((tag) => tag.toLowerCase()).toList();
      
      await _profileService.updateTagsForUser(userId, normalizedTags);
      
      // Refresh the tags from the server to ensure consistency
      final updatedTags = await _profileService.getTagsForUser(userId);
      state = AsyncData(updatedTags);
      
      // Return success
      return;
    } catch (e, stackTrace) {
      // Revert to previous state on error
      state = previousState;
      
      // Log the error for debugging
      developer.log('Error saving tags', error: e, stackTrace: stackTrace, name: 'EditTagsNotifier');
      
      // Re-throw the error to be handled by the UI
      rethrow;
    }
  }

  void reset() {
    _loadUserTags();
  }
}

// Provider for the edit tags notifier
final editTagsProvider = StateNotifierProvider<EditTagsNotifier, AsyncValue<List<String>>>((ref) {
  return EditTagsNotifier();
});
