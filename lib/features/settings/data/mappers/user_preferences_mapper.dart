import 'package:rivo_app_beta/features/settings/data/models/user_preferences_model.dart' as model;
import 'package:rivo_app_beta/features/settings/domain/entities/user_preferences.dart';

/// Mapper class to convert between [UserPreferences] entity and [UserPreferencesModel]
extension UserPreferencesMapper on UserPreferences {
  /// Converts a [UserPreferences] entity to a [UserPreferencesModel]
  model.UserPreferences toModel() {
    return model.UserPreferences(
      userId: userId,
      showPostUploadSuccessDialog: showPostUploadSuccessDialog,
      autoNavigateToPostAfterUpload: autoNavigateToPostAfterUpload,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

extension UserPreferencesModelMapper on model.UserPreferences {
  /// Converts a [UserPreferencesModel] to a [UserPreferences] entity
  UserPreferences toEntity() {
    return UserPreferences(
      userId: userId,
      showPostUploadSuccessDialog: showPostUploadSuccessDialog,
      autoNavigateToPostAfterUpload: autoNavigateToPostAfterUpload,
    );
  }
}
