import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/discovery/data/datasources/discovery_remote_data_source.dart';
import 'package:rivo_app_beta/features/discovery/data/repositories/discovery_repository_impl.dart';
import 'package:rivo_app_beta/features/discovery/domain/entities/discovery_tag_entity.dart';
import 'package:rivo_app_beta/features/discovery/domain/usecases/get_curated_tags_use_case.dart';
import 'package:rivo_app_beta/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rivo_app_beta/features/discovery/domain/usecases/get_featured_product_use_case.dart';
import 'package:rivo_app_beta/features/discovery/domain/entities/discovery_product_entity.dart';

// מקור יחיד לריפו
final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  final client = Supabase.instance.client;
  final remoteDataSource = DiscoveryRemoteDataSource(client: client);
  return DiscoveryRepositoryImpl(remoteDataSource: remoteDataSource);
});

// UseCase - GetCuratedTags
final getCuratedTagsUseCaseProvider = Provider<GetCuratedTagsUseCase>((ref) {
  final repository = ref.watch(discoveryRepositoryProvider);
  return GetCuratedTagsUseCase(repository);
});

// Provider שיחזיר את הרשימה ל־UI
final curatedTagsProvider = FutureProvider<List<DiscoveryTagEntity>>((ref) async {
  final useCase = ref.watch(getCuratedTagsUseCaseProvider);
  return useCase();
});

// UseCase
final getFeaturedProductUseCaseProvider = Provider<GetFeaturedProductUseCase>((ref) {
  final repository = ref.watch(discoveryRepositoryProvider);
  return GetFeaturedProductUseCase(repository);
});

// Provider לחשיפת המידע למסך
final featuredProductProvider = FutureProvider<DiscoveryProductEntity>((ref) async {
  final useCase = ref.watch(getFeaturedProductUseCaseProvider);
  return useCase();
});

final trendingTagsProvider = FutureProvider<List<DiscoveryTagEntity>>((ref) async {
  final repository = ref.watch(discoveryRepositoryProvider);
  return repository.getTrendingTags(); 
});

final curatedCollectionsProvider = FutureProvider.autoDispose((ref) {
  final repository = ref.watch(discoveryRepositoryProvider);
  return repository.getCuratedCollections();
});


