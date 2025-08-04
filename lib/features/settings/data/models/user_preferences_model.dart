import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  final String userId;
  final bool showPostUploadSuccessDialog;
  final bool autoNavigateToPostAfterUpload;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserPreferences({
    required this.userId,
    required this.showPostUploadSuccessDialog,
    required this.autoNavigateToPostAfterUpload,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPreferences.initial(String userId) => UserPreferences(
        userId: userId,
        showPostUploadSuccessDialog: true,
        autoNavigateToPostAfterUpload: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  UserPreferences copyWith({
    String? userId,
    bool? showPostUploadSuccessDialog,
    bool? autoNavigateToPostAfterUpload,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      showPostUploadSuccessDialog:
          showPostUploadSuccessDialog ?? this.showPostUploadSuccessDialog,
      autoNavigateToPostAfterUpload: autoNavigateToPostAfterUpload ?? this.autoNavigateToPostAfterUpload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'show_post_upload_success_dialog': showPostUploadSuccessDialog,
        'auto_navigate_to_post_after_upload': autoNavigateToPostAfterUpload,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['user_id'] as String,
      showPostUploadSuccessDialog: json['show_post_upload_success_dialog'] as bool? ?? true,
      autoNavigateToPostAfterUpload: json['auto_navigate_to_post_after_upload'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  List<Object> get props => [
        userId,
        showPostUploadSuccessDialog,
        autoNavigateToPostAfterUpload,
        createdAt,
        updatedAt,
      ];
}
