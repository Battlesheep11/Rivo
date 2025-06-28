import 'package:supabase_flutter/supabase_flutter.dart';

Future<bool> shouldShowOnboarding() async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return false;

  final profile = await Supabase.instance.client
      .from('profiles')
      .select('user_tags')
      .eq('id', userId)
      .maybeSingle();

  if (profile == null) return false;

  final tags = profile['user_tags'];
  return tags == null || (tags is List && tags.isEmpty);
}
