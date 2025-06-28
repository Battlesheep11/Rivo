import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default([]) List<String> visibleTags,
    @Default([]) List<String> selectedTags,
    @Default(false) bool isLoading,
  }) = _OnboardingState;
}
