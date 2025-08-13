import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/feed_remote_data_source.dart';
import '../../data/repositories/feed_repository_impl.dart';
import 'feed_repository.dart';
import 'dart:developer' as developer;

/// A Riverpod provider that creates and provides a singleton instance of [FeedRepository].
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  try {
    final client = Supabase.instance.client;
    final remoteDataSource = FeedRemoteDataSource(client: client);
    final repository = FeedRepositoryImpl(remoteDataSource: remoteDataSource);
    return repository;
  } catch (e, stackTrace) {
    developer.log(
      '❌ Error initializing feedRepositoryProvider: $e',
      name: 'FeedRepoProvider',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
});
