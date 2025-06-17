import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/feed_remote_data_source.dart';
import '../../data/repositories/feed_repository_impl.dart';
import 'feed_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final client = Supabase.instance.client;
  final remoteDataSource = FeedRemoteDataSource(client: client);
  return FeedRepositoryImpl(remoteDataSource: remoteDataSource);
});
