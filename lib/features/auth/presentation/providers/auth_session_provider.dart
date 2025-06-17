import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import 'package:rivo_app/features/auth/data/datasources/auth_remote_data_source_provider.dart';


final authSessionProvider = StreamProvider<UserEntity?>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return remoteDataSource.authStateChanges();
});

