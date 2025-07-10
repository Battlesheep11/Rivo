import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/features/onboarding/domain/repositories/tag_repository.dart';
import 'package:rivo_app_beta/features/onboarding/data/repositories/tag_repository_impl.dart';

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final client = Supabase.instance.client;
  return TagRepositoryImpl(client);
});
