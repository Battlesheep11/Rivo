import 'package:dartz/dartz.dart';
import 'package:rivo_app_beta/core/error_handling/failures.dart';
import 'package:rivo_app_beta/core/use_cases/use_case.dart';
import 'package:rivo_app_beta/features/post/domain/entities/tag_entity.dart';
import 'package:rivo_app_beta/features/post/domain/repositories/tags_repository.dart';

class GetTagsUseCase implements UseCase<List<TagEntity>, NoParams> {
  final TagsRepository _tagsRepository;

  GetTagsUseCase(this._tagsRepository);

  @override
  Future<Either<Failure, List<TagEntity>>> call(NoParams params) async {
    return await _tagsRepository.getTags();
  }
}
