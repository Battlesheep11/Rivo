import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rivo_app_beta/features/auth/domain/entities/user_entity.dart';
part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(UserEntity user) = _Authenticated;
  const factory AuthState.error(String message) = _Error;
}