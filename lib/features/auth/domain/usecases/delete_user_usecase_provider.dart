import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'delete_user_usecase.dart';
import '../repositories/delete_user_repository_provider.dart';

final deleteUserUseCaseProvider = Provider<DeleteUserUseCase>((ref) {
  final repository = ref.watch(deleteUserRepositoryProvider);
  return DeleteUserUseCase(repository: repository);
});
