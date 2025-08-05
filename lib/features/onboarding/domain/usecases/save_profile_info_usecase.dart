import 'package:rivo_app_beta/features/profile/domain/entities/user_profile_entity.dart';
import 'package:rivo_app_beta/features/profile/domain/repositories/profile_repository.dart';

/// A use case that saves or updates user profile info during onboarding.
///
/// Usage:
/// ```dart
/// final user = UserProfileEntity(
///   id: userId,
///   firstName: 'Dana',
///   lastName: 'G',
///   avatarUrl: 'https://.../somepic.png',
///   bio: 'Love secondhand!',
///   language: 'he',
/// );
///
/// await saveProfileInfoUseCase.execute(user);
/// ```
class SaveProfileInfoUseCase {
  final ProfileRepository _repository;

  SaveProfileInfoUseCase(this._repository);

  Future<void> execute(UserProfileEntity user) {
    return _repository.updateUserProfile(user);
  }
}
