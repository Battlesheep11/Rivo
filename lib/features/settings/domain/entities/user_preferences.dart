import 'package:equatable/equatable.dart';

/// Represents the user's preferences for the app.
class UserPreferences extends Equatable {
  /// The user's unique ID
  final String userId;

  /// Whether to show the success dialog after a post is uploaded
  final bool showPostUploadSuccessDialog;

  /// Whether to automatically navigate to the post after upload
  final bool autoNavigateToPostAfterUpload;

  /// Creates a new [UserPreferences] instance.
  const UserPreferences({
    required this.userId,
    this.showPostUploadSuccessDialog = true,
    this.autoNavigateToPostAfterUpload = false,
  });

  /// Creates a copy of this [UserPreferences] with the given fields replaced.
  UserPreferences copyWith({
    String? userId,
    bool? showPostUploadSuccessDialog,
    bool? autoNavigateToPostAfterUpload,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      showPostUploadSuccessDialog: showPostUploadSuccessDialog ?? this.showPostUploadSuccessDialog,
      autoNavigateToPostAfterUpload: autoNavigateToPostAfterUpload ?? this.autoNavigateToPostAfterUpload,
    );
  }

  /// Creates a [Map] representation of this [UserPreferences].
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'show_post_upload_success_dialog': showPostUploadSuccessDialog,
      'auto_navigate_to_post_after_upload': autoNavigateToPostAfterUpload,
    };
  }

  /// Creates a [UserPreferences] from a [Map].
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      userId: map['user_id'] as String,
      showPostUploadSuccessDialog: map['show_post_upload_success_dialog'] as bool? ?? true,
      autoNavigateToPostAfterUpload: map['auto_navigate_to_post_after_upload'] as bool? ?? false,
    );
  }

  @override
  List<Object> get props => [
        userId,
        showPostUploadSuccessDialog,
        autoNavigateToPostAfterUpload,
      ];

  @override
  bool get stringify => true;
}
