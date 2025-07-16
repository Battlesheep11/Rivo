import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userHasTagsProvider = FutureProvider.autoDispose<bool>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    return false;
  }

  try {
    final userTagRows = await Supabase.instance.client
        .from('user_tags')
        .select('tag_id')
        .eq('user_id', user.id);

    return userTagRows.isNotEmpty;
  } catch (e) {
    return false; // Fallback
  }
});
