import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:rivo_app_beta/features/profile/data/repositories/profile_remote_data_source_impl.dart';
import 'package:rivo_app_beta/features/profile/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = Supabase.instance.client;
  final remoteDataSource = ProfileRemoteDataSource(client: client);
  return ProfileRepositoryImpl(remoteDataSource: remoteDataSource);
});
