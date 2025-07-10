import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/onboarding/domain/repositories/tag_repository.dart';
import 'package:rivo_app_beta/features/onboarding/domain/repositories/tag_repository_provider.dart';

final submitUserTagsUseCaseProvider = Provider<SubmitUserTagsUseCase>((ref) {
  final repository = ref.watch(tagRepositoryProvider);
  return SubmitUserTagsUseCase(repository);
});

class SubmitUserTagsUseCase {
  final TagRepository _repository;

  SubmitUserTagsUseCase(this._repository);

  Future<void> execute(List<String> tagNames) async {
    await _repository.submitUserTags(tagNames);
  }
  
}
