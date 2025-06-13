import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'auth_remote_data_source.dart';
import 'package:rivo_app/core/supabase/supabase_client.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(client: SupabaseClientManager.client);
});
