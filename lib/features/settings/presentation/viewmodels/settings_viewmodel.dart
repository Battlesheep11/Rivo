import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/core/state/app_state.dart';
import 'package:rivo_app_beta/features/settings/domain/entities/user_preferences.dart';
import 'package:rivo_app_beta/features/settings/domain/usecases/get_user_preferences.dart';
import 'package:rivo_app_beta/features/settings/domain/usecases/update_user_preferences.dart';
import 'package:rivo_app_beta/features/settings/domain/usecases/initialize_user_preferences.dart';


class SettingsViewModel extends StateNotifier<AppState<UserPreferences>> {
  bool get isLoaded => state is SuccessAppState<UserPreferences>;
  final GetUserPreferences _getUserPreferences;
  final UpdateUserPreferences _updateUserPreferences;
  final String userId;
  final InitializeUserPreferences _initializeUserPreferences;

  SettingsViewModel({
    required GetUserPreferences getUserPreferences,
    required UpdateUserPreferences updateUserPreferences,
    required InitializeUserPreferences initializeUserPreferences,
    required this.userId,
  })  : _getUserPreferences = getUserPreferences,
        _updateUserPreferences = updateUserPreferences,
        _initializeUserPreferences = initializeUserPreferences,
        super(const AppState.initial());

  Future<void> loadPreferences() async {
    state = const AppState.loading();
    final result = await _getUserPreferences(userId);
    await result.fold(
      (failure) async {
        // If preferences not found, try to initialize
        if (failure.message.toLowerCase().contains('not found')) {
          final initResult = await _initializeUserPreferences(userId);
          state = initResult.fold(
            (initFailure) => AppState.error(initFailure, StackTrace.current),
            (prefs) => AppState.success(prefs),
          );
        } else {
          state = AppState.error(failure, StackTrace.current);
        }
      },
      (prefs) async {
        state = AppState.success(prefs);
      },
    );
  }

    Future<void> updatePreferences(UserPreferences newPreferences) async {
    await _updateAndSavePreferences(newPreferences);
  }

  Future<void> _updateAndSavePreferences(UserPreferences prefs) async {
    state = AppState.loading(prefs);
    final result = await _updateUserPreferences(prefs);
    state = result.fold(
      (failure) => AppState.error(
        failure,
        StackTrace.current,
      ),
      (_) => AppState.success(prefs),
    );
  }

  // Check if this is the first time the user is seeing the post-upload dialog
  bool get shouldShowFirstTimeDialog {
    return state.maybeWhen(
      success: (UserPreferences prefs) => prefs.showPostUploadSuccessDialog,
      orElse: () => true, // Default to showing the dialog if we can't load prefs
    );
  }
  
  // Getters for the current state of the preferences
  bool get showPostUploadDialog {
    return state.maybeWhen(
      success: (prefs) => prefs.showPostUploadSuccessDialog,
      orElse: () => true, // Default to true if not loaded yet
    );
  }
  
  bool get autoNavigateToPost {
    return state.maybeWhen(
      success: (prefs) => prefs.autoNavigateToPostAfterUpload,
      orElse: () => false, // Default to false if not loaded yet
    );
  }

  // Check if we should auto-navigate to the post after upload
  bool get shouldAutoNavigateToPost {
    return state.maybeWhen(
      success: (prefs) => prefs.autoNavigateToPostAfterUpload,
      orElse: () => false, // Default to not auto-navigating if we can't load prefs
    );
  }
}
