import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
