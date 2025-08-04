import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/features/settings/data/models/user_preferences_model.dart' as model;

/// Custom exception for user preferences related errors
class UserPreferencesException implements Exception {
  final String message;
  UserPreferencesException(this.message);

  @override
  String toString() => 'UserPreferencesException: $message';
}

abstract class UserPreferencesRemoteDataSource {
  Future<model.UserPreferences> getUserPreferences(String userId);
  Future<model.UserPreferences> updateUserPreferences(model.UserPreferences preferences);
  Future<model.UserPreferences> initializeUserPreferences(String userId);
}

class UserPreferencesRemoteDataSourceImpl implements UserPreferencesRemoteDataSource {
  final SupabaseClient supabaseClient;

  UserPreferencesRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<model.UserPreferences> getUserPreferences(String userId) async {
    try {
      final response = await supabaseClient
          .from('user_preferences')
          .select()
          .eq('user_id', userId)
          .single();

      return model.UserPreferences.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // Not found - initialize preferences
        return initializeUserPreferences(userId);
      }
      throw UserPreferencesException('Failed to get user preferences: ${e.message}');
    } catch (e) {
      throw UserPreferencesException('Unexpected error getting preferences: $e');
    }
  }

  @override
  Future<model.UserPreferences> updateUserPreferences(model.UserPreferences preferences) async {
    try {
      final response = await supabaseClient
          .from('user_preferences')
          .upsert(
            preferences.toJson()..remove('created_at'), // Don't update created_at
            onConflict: 'user_id',
          )
          .select()
          .single();

      return model.UserPreferences.fromJson(response);
    } on PostgrestException catch (e) {
      throw UserPreferencesException('Failed to update user preferences: ${e.message}');
    } catch (e) {
      throw UserPreferencesException('Unexpected error updating preferences: $e');
    }
  }

  @override
  Future<model.UserPreferences> initializeUserPreferences(String userId) async {
    try {
      final defaultPrefs = model.UserPreferences.initial(userId);
      
      final response = await supabaseClient
          .from('user_preferences')
          .insert(defaultPrefs.toJson())
          .select()
          .single();

      return model.UserPreferences.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') { // Unique violation - preferences already exist
        // Try to fetch existing preferences
        return getUserPreferences(userId);
      }
      throw UserPreferencesException('Failed to initialize user preferences: ${e.message}');
    } catch (e) {
      throw UserPreferencesException('Unexpected error initializing preferences: $e');
    }
  }
}
