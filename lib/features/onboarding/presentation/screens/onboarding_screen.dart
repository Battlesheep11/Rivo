import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo_app_beta/features/onboarding/presentation/viewmodels/onboarding_view_model.dart';
import 'package:rivo_app_beta/features/onboarding/presentation/widgets/tag_selector_widget.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

   
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingViewModelProvider.notifier).loadTags();
    });
  }

  void _goToNextPage() {
    if (_currentPage < 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        children: [
          _buildWelcomePage(t),
          _buildTagSelectionPage(t),
        ],
      ),
    );
  }

  Widget _buildWelcomePage(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            t.onboardingWelcomeTitle,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            t.onboardingWelcomeSubtitle,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _goToNextPage,
            child: Text(t.onboardingStartButton),
          ),
        ],
      ),
    );
  }

  Widget _buildTagSelectionPage(AppLocalizations t) {
    final viewModel = ref.read(onboardingViewModelProvider.notifier);
    final selectedTags = ref.watch(onboardingViewModelProvider.select((s) => s.selectedTags));
    final isButtonEnabled = selectedTags.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.onboardingTagSelectionTitle,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Expanded(
            child: TagSelectorWidget(),
          ),
          ElevatedButton(
            onPressed: isButtonEnabled
                ? () async {
                    await viewModel.submitTags();
                    if (!mounted) return;
                    context.go('/home');
                  }
                : null,
            child: Text(t.onboardingFinishButton),
          ),
        ],
      ),
    );
  }
}
