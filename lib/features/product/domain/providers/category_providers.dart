import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final categoryNameProvider = FutureProvider.family<String, String>((ref, categoryId) async {
  final response = await Supabase.instance.client
      .from('categories')
      .select('name')
      .eq('id', categoryId)
      .maybeSingle();

  if (response == null || response['name'] == null) {
    throw Exception('Category not found');
  }

  return response['name'] as String;
});
