import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'delete_user_repository.dart';

final deleteUserRepositoryProvider = Provider<DeleteUserRepository>((ref) {
  final client = Supabase.instance.client;
  return SupabaseDeleteUserRepository(client: client);
});
