import 'package:flutter/material.dart';
import 'package:rivo_app_beta/core/analytics/analytics_service.dart';

final AnalyticsNavigatorObserver analyticsObserver = AnalyticsNavigatorObserver();

class AnalyticsNavigatorObserver extends NavigatorObserver {
  void _sendScreenView(Route<dynamic>? route) {
    if (route is PageRoute) {
      final screenName = route.settings.name;
      if (screenName != null) {
        AnalyticsService.logScreenView(screenName: screenName); // ✅ העברנו לפי שם פרמטר
      }
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _sendScreenView(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _sendScreenView(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _sendScreenView(previousRoute);
  }
}
