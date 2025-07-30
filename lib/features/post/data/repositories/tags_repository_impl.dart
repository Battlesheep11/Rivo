import 'package:dartz/dartz.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/core/error_handling/failures.dart';
import 'package:rivo_app_beta/features/post/data/datasources/tags_datasource.dart';
import 'package:rivo_app_beta/features/post/domain/entities/tag_entity.dart';
import 'package:rivo_app_beta/features/post/domain/repositories/tags_repository.dart';

class TagsRepositoryImpl implements TagsRepository {
  final TagsDataSource _tagsDataSource;

  TagsRepositoryImpl(this._tagsDataSource);

  @override
  Future<Either<Failure, List<TagEntity>>> getTags() async {
    try {
      final tags = await _tagsDataSource.getTags();
      return Right(tags);
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
