abstract class TagRepository {
  Future<void> submitUserTags(List<String> tagNames);
  Future<List<String>> getAllVisibleTags();
}
