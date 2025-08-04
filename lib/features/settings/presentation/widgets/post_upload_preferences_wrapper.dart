import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo_app_beta/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:rivo_app_beta/features/settings/domain/services/post_upload_preferences_service.dart';
import 'package:rivo_app_beta/features/settings/presentation/providers/settings_providers.dart';


class PostUploadPreferencesWrapper extends ConsumerStatefulWidget {
  final Widget child;
  
  const PostUploadPreferencesWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<PostUploadPreferencesWrapper> createState() => _PostUploadPreferencesWrapperState();
}

class _PostUploadPreferencesWrapperState extends ConsumerState<PostUploadPreferencesWrapper> {
  bool _initialized = false;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndShowPrompt();
  }
  
  Future<void> _checkAndShowPrompt() async {
    if (_initialized) return;

    final authState = ref.watch(authSessionProvider);
    final user = authState.asData?.value;
    if (user == null) return;

    final viewModel = ref.read(settingsViewModelProvider(user.id).notifier);

    final service = PostUploadPreferencesService(
      context: context,
      userId: user.id,
      viewModel: viewModel,
    );

    await service.showFirstTimePromptIfNeeded();

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
