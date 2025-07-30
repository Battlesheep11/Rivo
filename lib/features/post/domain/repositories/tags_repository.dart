import 'package:dartz/dartz.dart';
import 'package:rivo_app_beta/core/error_handling/failures.dart';
import 'package:rivo_app_beta/features/post/domain/entities/tag_entity.dart';

abstract class TagsRepository {
  Future<Either<Failure, List<TagEntity>>> getTags();
}
