import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart'; // For NavigatorObserver

/// Service for tracking user engagement and app usage
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  /// Log a custom event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      debugPrint('Analytics: Logged event $name');
    } catch (e) {
      debugPrint('Analytics: Failed to log event $name: $e');
    }
  }

  /// Log a screen view
  Future<void> logScreenView({required String screenName}) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
      debugPrint('Analytics: Logged screen view $screenName');
    } catch (e) {
      debugPrint('Analytics: Failed to log screen view $screenName: $e');
    }
  }

  /// Set a user property
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Analytics: Failed to set user property $name: $e');
    }
  }

  /// Set user ID
  Future<void> setUserId(String? id) async {
    try {
      await _analytics.setUserId(id: id);
    } catch (e) {
      debugPrint('Analytics: Failed to set user ID: $e');
    }
  }

  /// Get the analytics observer for navigation tracking
  NavigatorObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }
}
