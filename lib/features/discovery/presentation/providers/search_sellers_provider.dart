import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app/features/discovery/data/datasources/search_remote_data_source.dart';
import 'package:rivo_app/features/discovery/data/repositories/search_repository_impl.dart';
import 'package:rivo_app/features/discovery/domain/repositories/search_repository.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final client = Supabase.instance.client;
  final remoteDataSource = SearchRemoteDataSource(client); 
  return SearchRepositoryImpl(remoteDataSource);
});
