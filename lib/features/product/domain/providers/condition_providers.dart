import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app_beta/features/product/domain/entities/condition_option.dart';
import 'package:rivo_app_beta/features/product/data/product_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// DI של SupabaseClient לפי הפרויקט
final supabaseClientProvider = Provider<SupabaseClient>((_) {
  throw UnimplementedError('Provide SupabaseClient via override');
});

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProductRemoteDataSource(client: client);
});

final conditionOptionsProvider = FutureProvider<List<ConditionOption>>((ref) async {
  final ds = ref.watch(productRemoteDataSourceProvider);
  final rows = await ds.getItemConditions(); // code, display_order, is_active
  final options = rows.map(ConditionOption.fromMap).toList(growable: false)
    ..sort((a, b) => a.order.compareTo(b.order));
  return options;
});
