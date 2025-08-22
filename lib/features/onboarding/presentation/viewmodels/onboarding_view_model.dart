import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/onboarding/domain/usecases/get_visible_tags_usecase.dart';
import 'package:rivo_app_beta/features/onboarding/domain/usecases/submit_user_tags_usecase.dart';

final onboardingViewModelProvider =
    StateNotifierProvider<OnboardingViewModel, OnboardingState>(
  (ref) => OnboardingViewModel(
    getTagsUseCase: ref.watch(getVisibleTagsUseCaseProvider),
    submitTagsUseCase: ref.watch(submitUserTagsUseCaseProvider),
  ),
);

class OnboardingViewModel extends StateNotifier<OnboardingState> {
  final GetVisibleTagsUseCase getTagsUseCase;
  final SubmitUserTagsUseCase submitTagsUseCase;

  OnboardingViewModel({
  required this.getTagsUseCase,
  required this.submitTagsUseCase,
}) : super(OnboardingState.initial()); 



  Future<void> loadTags() async {
    state = state.copyWith(isLoading: true);
    try {
      final tags = await getTagsUseCase.execute();
      state = state.copyWith(allTags: tags, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void toggleTag(String tagName) {
    final current = [...state.selectedTags];
    if (current.contains(tagName)) {
      current.remove(tagName);
    } else {
      current.add(tagName);
    }
    state = state.copyWith(selectedTags: current);
  }

  Future<void> submitTags() async {
    if (state.selectedTags.isEmpty) return;
    await submitTagsUseCase.execute(state.selectedTags);
  }

void setUTMParams(Map<String, String> params) {
  state = state.copyWith(utmParams: params);
}


}

class OnboardingState {
  final List<String> allTags;
  final List<String> selectedTags;
  final bool isLoading;
  final Map<String, String> utmParams;


  const OnboardingState({
    required this.allTags,
    required this.selectedTags,
    required this.isLoading,
    required this.utmParams,
  });

  factory OnboardingState.initial() {
    return const OnboardingState(
      allTags: [],
      selectedTags: [],
      isLoading: false,
      utmParams: {},
    );
  }

  OnboardingState copyWith({
    List<String>? allTags,
    List<String>? selectedTags,
    bool? isLoading,
    Map<String, String>? utmParams,
  }) {
    return OnboardingState(
      allTags: allTags ?? this.allTags,
      selectedTags: selectedTags ?? this.selectedTags,
      isLoading: isLoading ?? this.isLoading,
      utmParams: utmParams ?? this.utmParams,
    );
  }
}
