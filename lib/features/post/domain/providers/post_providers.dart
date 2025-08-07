import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'package:rivo_app_beta/features/post/data/datasources/post_remote_data_source.dart';
import 'package:rivo_app_beta/features/post/data/repositories/post_repository_impl.dart';
import 'package:rivo_app_beta/features/post/domain/repositories/post_repository.dart';
import 'package:rivo_app_beta/features/post/domain/usecases/upload_post_use_case.dart';
import 'package:rivo_app_beta/features/post/data/datasources/tags_datasource.dart';
import 'package:rivo_app_beta/features/post/domain/repositories/tags_repository.dart';
import 'package:rivo_app_beta/features/post/data/repositories/tags_repository_impl.dart';
import 'package:rivo_app_beta/features/post/domain/usecases/get_tags_use_case.dart';
import 'package:rivo_app_beta/features/post/domain/entities/tag_entity.dart';
import 'package:rivo_app_beta/core/use_cases/use_case.dart';

final postRemoteDataSourceProvider = Provider<PostRemoteDataSource>((ref) {
  final client = Supabase.instance.client;
  return PostRemoteDataSource(client: client);
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final remoteDataSource = ref.watch(postRemoteDataSourceProvider);
  return PostRepositoryImpl(remoteDataSource: remoteDataSource);
});

final uploadPostUseCaseProvider = Provider<UploadPostUseCase>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return UploadPostUseCase(repository);
});

final tagsDataSourceProvider = Provider<TagsDataSource>((ref) {
  final client = Supabase.instance.client;
  return TagsDataSourceImpl(client);
});

final tagsRepositoryProvider = Provider<TagsRepository>((ref) {
  final remoteDataSource = ref.watch(tagsDataSourceProvider);
  return TagsRepositoryImpl(remoteDataSource);
});

final getTagsUseCaseProvider = Provider<GetTagsUseCase>((ref) {
  final repository = ref.watch(tagsRepositoryProvider);
  return GetTagsUseCase(repository);
});

final tagsProvider = FutureProvider<List<TagEntity>>((ref) async {
  final getTags = ref.watch(getTagsUseCaseProvider);
  final result = await getTags(NoParams());
  return result.fold(
    (failure) => throw failure,
    (tags) => tags,
  );
});
