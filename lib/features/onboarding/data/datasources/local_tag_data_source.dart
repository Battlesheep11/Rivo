import 'package:rivo_app_beta/features/onboarding/domain/entities/tag_entity.dart';

class LocalTagDataSource {
  List<TagEntity> getAvailableTags() {
    return const [
      TagEntity(name: 'vintage'),
      TagEntity(name: 'minimalism'),
      TagEntity(name: 'streetwear'),
      TagEntity(name: 'urban'),
      TagEntity(name: 'secondhand'),
      TagEntity(name: 'sustainable'),
      TagEntity(name: 'colorful'),
      TagEntity(name: 'retro'),
      TagEntity(name: 'Y2K'),
      TagEntity(name: 'oversized'),
      TagEntity(name: 'clean'),
      TagEntity(name: 'ethical'),
      TagEntity(name: 'handmade'),
      TagEntity(name: 'festival'),
      TagEntity(name: 'school'),
      TagEntity(name: 'office'),
      TagEntity(name: 'date night'),
      TagEntity(name: 'local brands'),
    ];
  }
}
