import 'package:flutter/material.dart';


import 'package:rivo_app_beta/features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'package:rivo_app_beta/features/settings/presentation/widgets/post_upload_preferences_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostUploadPreferencesService {
  static const String _hasShownFirstTimePromptKey = 'has_shown_post_upload_preferences_prompt';
  
  final BuildContext context;
  final String userId;
  final SettingsViewModel viewModel;
  
  PostUploadPreferencesService({
    required this.context,
    required this.userId,
    required this.viewModel,
  });
  
  /// Checks if we should show the first-time prompt for post-upload preferences
  Future<bool> shouldShowFirstTimePrompt() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_hasShownFirstTimePromptKey) ?? false);
  }
  
  /// Shows the first-time prompt for post-upload preferences if needed
  Future<void> showFirstTimePromptIfNeeded() async {
    final shouldShow = await shouldShowFirstTimePrompt();
    if (!shouldShow) return;
    
    if (!context.mounted) return;
    
    // Check if the view model has loaded the preferences
    if (!viewModel.isLoaded) {
      // If not loaded yet, wait for it
      await viewModel.loadPreferences();
    }
    
    if (!context.mounted) return;
    
    // Show the dialog
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PostUploadPreferencesDialog(userId: userId),
    );
    
    // Mark as shown if the user made a selection
    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasShownFirstTimePromptKey, true);
    }
  }
  
  /// Resets the first-time prompt flag (for testing or if user wants to see it again)
  static Future<void> resetFirstTimePrompt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasShownFirstTimePromptKey);
  }
}
