import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_repository_impl.dart';
import 'package:rivo_app/features/auth/data/datasources/auth_remote_data_source_provider.dart';


final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
});
