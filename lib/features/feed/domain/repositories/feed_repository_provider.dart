import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/feed_remote_data_source.dart';
import '../../data/repositories/feed_repository_impl.dart';
import 'feed_repository.dart';
import 'dart:developer' as developer;

/// A Riverpod provider that creates and provides a singleton instance of [FeedRepository].
///
/// This provider is responsible for:
/// - Initializing the repository with its dependencies
/// - Managing the repository's lifecycle
/// - Providing error handling and logging
/// 
/// Dependencies:
/// - [Supabase] client for database operations
/// - [FeedRemoteDataSource] for remote data operations
/// - [FeedRepositoryImpl] as the concrete implementation of [FeedRepository]
///
/// The provider is scoped to the application's lifecycle and creates the repository
/// lazily when first accessed.
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  try {
    // Get the Supabase client instance
    final client = Supabase.instance.client;
    
    // Initialize the remote data source with the Supabase client
    final remoteDataSource = FeedRemoteDataSource(client: client);
    
    // Create and return the repository implementation with the remote data source
    final repository = FeedRepositoryImpl(remoteDataSource: remoteDataSource);
    return repository;
  } catch (e, stackTrace) {
    // Log detailed error information for debugging
    developer.log(
      '❌ Error initializing feedRepositoryProvider: $e',
      name: 'FeedRepoProvider',
      error: e,
      stackTrace: stackTrace,
    );
    
    // Re-throw to allow error handling by the caller
    rethrow;
  }
});
