import 'package:rivo_app/features/discovery/domain/entities/discovery_tag_entity.dart';
import 'package:rivo_app/features/discovery/domain/repositories/discovery_repository.dart';


class GetCuratedTagsUseCase {
  final DiscoveryRepository repository;

  GetCuratedTagsUseCase(this.repository);

  Future<List<DiscoveryTagEntity>> call() {
    return repository.getCuratedTags();
  }
}
