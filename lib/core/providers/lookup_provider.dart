import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final lookupProvider = FutureProvider<LookupData>((ref) async {
  final client = Supabase.instance.client;

  final results = await Future.wait([
    client.from('product_statuses').select('code'), // display_name הוסר
    client.from('item_conditions').select('code').order('display_order'),
    client.from('materials').select('code'),
    client.from('colors').select('code, hex'),
    client.from('defect_types').select('code'),
  ]);

  return LookupData.fromSupabase(results);
});

class LookupData {
  final List<LookupItem> statuses;
  final List<LookupItem> conditions;
  final List<LookupItem> materials;
  final List<ColorItem> colors;
  final List<LookupItem> defectTypes;

  LookupData({
    required this.statuses,
    required this.conditions,
    required this.materials,
    required this.colors,
    required this.defectTypes,
  });

  factory LookupData.fromSupabase(List<List<dynamic>> results) {
    return LookupData(
      statuses: (results[0]).map((e) => LookupItem.fromMap(e)).toList(),
      conditions: (results[1]).map((e) => LookupItem.fromMap(e)).toList(),
      materials: (results[2]).map((e) => LookupItem.fromMap(e)).toList(),
      colors: (results[3]).map((e) => ColorItem.fromMap(e)).toList(),
      defectTypes: (results[4]).map((e) => LookupItem.fromMap(e)).toList(),
    );
  }
}

class LookupItem {
  final String code;

  LookupItem({required this.code});

  factory LookupItem.fromMap(Map<String, dynamic> map) {
    return LookupItem(
      code: map['code'] as String,
    );
  }
}

class ColorItem {
  final String code;
  final String hex;

  ColorItem({
    required this.code,
    required this.hex,
  });

  factory ColorItem.fromMap(Map<String, dynamic> map) {
    return ColorItem(
      code: map['code'] as String,
      hex: map['hex'] as String,
    );
  }
}
