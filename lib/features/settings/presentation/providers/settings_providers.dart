import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/state/app_state.dart';
import 'package:rivo_app_beta/features/settings/domain/entities/user_preferences.dart';
import 'package:rivo_app_beta/features/settings/data/datasources/user_preferences_remote_data_source.dart';
import 'package:rivo_app_beta/features/settings/data/repositories/user_preferences_repository_impl.dart';
import 'package:rivo_app_beta/features/settings/domain/repositories/user_preferences_repository.dart';
import 'package:rivo_app_beta/features/settings/domain/usecases/get_user_preferences.dart';
import 'package:rivo_app_beta/features/settings/domain/usecases/update_user_preferences.dart';
import 'package:rivo_app_beta/features/settings/domain/usecases/initialize_user_preferences.dart';
import 'package:rivo_app_beta/features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Remote Data Source
final userPreferencesRemoteDataSourceProvider = Provider<UserPreferencesRemoteDataSource>(
  (ref) => UserPreferencesRemoteDataSourceImpl(
    supabaseClient: Supabase.instance.client,
  ),
);

// Repository
final userPreferencesRepositoryProvider = Provider<UserPreferencesRepository>(
  (ref) => UserPreferencesRepositoryImpl(
    remoteDataSource: ref.watch(userPreferencesRemoteDataSourceProvider),
  ),
);

// Use Cases
final getUserPreferencesProvider = Provider<GetUserPreferences>(
  (ref) => GetUserPreferences(
    ref.watch(userPreferencesRepositoryProvider),
  ),
);

final updateUserPreferencesProvider = Provider<UpdateUserPreferences>(
  (ref) => UpdateUserPreferences(
    ref.watch(userPreferencesRepositoryProvider),
  ),
);

final initializeUserPreferencesProvider = Provider<InitializeUserPreferences>(
  (ref) => InitializeUserPreferences(
    ref.watch(userPreferencesRepositoryProvider),
  ),
);

// ViewModel
final settingsViewModelProvider = StateNotifierProvider.family<SettingsViewModel, AppState<UserPreferences>, String>(
  (ref, userId) => SettingsViewModel(
    getUserPreferences: ref.watch(getUserPreferencesProvider),
    updateUserPreferences: ref.watch(updateUserPreferencesProvider),
    initializeUserPreferences: ref.watch(initializeUserPreferencesProvider),
    userId: userId,
  )..loadPreferences(),
);
