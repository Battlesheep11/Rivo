import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/profile/domain/repositories/profile_repository_provider.dart';
import 'save_profile_info_usecase.dart';

final saveProfileInfoUseCaseProvider = Provider<SaveProfileInfoUseCase>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return SaveProfileInfoUseCase(repo);
});
