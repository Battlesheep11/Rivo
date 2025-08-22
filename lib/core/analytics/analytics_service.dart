import 'package:firebase_analytics/firebase_analytics.dart';

/// Centralized analytics service for Firebase Analytics.
///
/// Use this service to log screen views, custom events,
/// user properties, and manage user ID.
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Logs when the app is opened.
  static Future<void> logAppOpened() async {
    await _analytics.logAppOpen();
  }

  /// Logs a screen view with a given name.
  static Future<void> logScreenView({
    required String screenName,
    String? screenClassOverride,
  }) async {
    await _analytics.logEvent(
      name: 'screen_view',
      parameters: {
        'firebase_screen': screenName,
        'firebase_screen_class': screenClassOverride ?? screenName,
      },
    );
  }

  /// Logs a custom event with optional parameters.
  static Future<void> logEvent(String name, {
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  /// Sets a user property (e.g., user_type = seller).
  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  /// Sets the user ID to associate events with a specific user.
  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }
}
