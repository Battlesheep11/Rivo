import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/core/entities/category.dart';

final categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  final response = await Supabase.instance.client
      .from('categories')
      .select('id, name')
      .eq('is_deleted', false)
      .order('name');

  return (response as List)
      .map((item) => Category.fromMap(item as Map<String, dynamic>))
      .toList();
});
