import 'package:flutter/foundation.dart';

/// A service to handle rate limiting for authentication attempts
class RateLimiterService {
  // Maximum number of attempts allowed within the time window
  static const int maxAttempts = 5;
  
  // Time window for rate limiting (5 minutes)
  static const Duration attemptWindow = Duration(minutes: 5);
  
  // Track login attempts by identifier (e.g., IP address or email)
  final Map<String, List<DateTime>> _loginAttempts = {};
  
  /// Check if a login attempt is allowed for the given identifier
  /// Returns null if allowed, or an error message if rate limited
  String? checkLoginAttempt(String identifier) {
    // Clean up old attempts
    _cleanupOldAttempts(identifier);
    
    // Get current attempts
    final attempts = _loginAttempts[identifier] ?? [];
    
    // Check if we've exceeded the rate limit
    if (attempts.length >= maxAttempts) {
      return 'Too many login attempts. Please try again later.';
    }
    
    return null;
  }
  
  /// Record a login attempt for the given identifier
  void recordLoginAttempt(String identifier) {
    _loginAttempts.putIfAbsent(identifier, () => []).add(DateTime.now());
    
    // Clean up old attempts
    _cleanupOldAttempts(identifier);
  }
  
  /// Reset the login attempt counter for a successful login
  void resetLoginAttempts(String identifier) {
    _loginAttempts.remove(identifier);
  }
  
  void _cleanupOldAttempts(String identifier) {
    final now = DateTime.now();
    final attempts = _loginAttempts[identifier];
    if (attempts == null) return;
    
    _loginAttempts[identifier] = attempts
        .where((attempt) => now.difference(attempt) <= attemptWindow)
        .toList();
        
    if (_loginAttempts[identifier]!.isEmpty) {
      _loginAttempts.remove(identifier);
    }
  }
  
  // For testing and debugging
  @visibleForTesting
  void clear() {
    _loginAttempts.clear();
  }
}
