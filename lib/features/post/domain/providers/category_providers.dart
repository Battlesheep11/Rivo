import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/core/entities/category.dart';

final categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  log('Fetching categories...');
  final response = await Supabase.instance.client
      .from('categories')
      .select('id, name')
      .eq('is_deleted', false)
      .order('name');

  return (response as List)
      .map((item) => Category.fromMap(item as Map<String, dynamic>))
      .toList();
});

final categoryByIdProvider =
    FutureProvider.autoDispose.family<Category?, String?>((ref, categoryId) async {
  if (categoryId == null || categoryId.isEmpty) {
    return null;
  }

  final response = await Supabase.instance.client
      .from('categories')
      .select('id, name')
      .eq('id', categoryId)
      .maybeSingle();

  if (response == null) {
    return null;
  }

  return Category.fromMap(response);
});
