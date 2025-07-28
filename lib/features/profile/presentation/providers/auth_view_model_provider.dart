import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/auth/presentation/state/auth_state.dart';
import 'package:rivo_app_beta/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:rivo_app_beta/features/auth/domain/repositories/auth_repository_provider.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthViewModel(repository: repository);
});
