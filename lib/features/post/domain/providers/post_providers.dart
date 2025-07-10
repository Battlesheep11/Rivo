import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/features/post/data/datasources/post_remote_data_source.dart';
import 'package:rivo_app_beta/features/post/data/repositories/post_repository_impl.dart';
import 'package:rivo_app_beta/features/post/domain/repositories/post_repository.dart';
import 'package:rivo_app_beta/features/post/domain/usecases/upload_post_use_case.dart';

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
