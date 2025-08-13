import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DeleteUserRepository {
  Future<bool> deleteUser();
}

class SupabaseDeleteUserRepository implements DeleteUserRepository {
  final SupabaseClient client;

  SupabaseDeleteUserRepository({required this.client});

  @override
  Future<bool> deleteUser() async {
    final response = await client.functions.invoke('delete_user_self');

    // status is non-null in v2, so no null-coalescing
    if (response.status >= 400) {
      final errorMessage = (response.data is Map)
          ? (response.data as Map)['error'] ?? 'Unknown error'
          : 'Unknown error';
      throw Exception('Failed to delete user: $errorMessage');
    }

    return true;
  }
}
