import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/onboarding/domain/repositories/tag_repository.dart';
import 'package:rivo_app_beta/features/onboarding/domain/repositories/tag_repository_provider.dart';

class GetVisibleTagsUseCase {
  final TagRepository repository;

  GetVisibleTagsUseCase(this.repository);

  Future<List<String>> execute() {
    return repository.getAllVisibleTags();
  }
}

final getVisibleTagsUseCaseProvider = Provider<GetVisibleTagsUseCase>((ref) {
  final repository = ref.watch(tagRepositoryProvider);
  return GetVisibleTagsUseCase(repository);
});
