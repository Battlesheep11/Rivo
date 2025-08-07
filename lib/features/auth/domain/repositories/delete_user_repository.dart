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

    if ((response.status ?? 500) >= 400) {
      final errorMessage = response.data?['error'] ?? 'Unknown error';
      throw Exception('Failed to delete user: $errorMessage');
    }

    // Optionally inspect response.data if needed
    return true;
  }
}
