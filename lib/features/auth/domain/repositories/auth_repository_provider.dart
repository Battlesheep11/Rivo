import 'package:rivo_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rivo_app/features/auth/data/datasources/auth_remote_data_source_provider.dart';
import 'package:rivo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
});
