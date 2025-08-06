import '../repositories/delete_user_repository.dart';

class DeleteUserUseCase {
  final DeleteUserRepository repository;

  DeleteUserUseCase({required this.repository});

  Future<void> call() async {
    await repository.deleteUser();
  }
}
