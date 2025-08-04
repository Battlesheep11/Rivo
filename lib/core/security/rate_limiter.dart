import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';

/// A service for rate limiting API requests to prevent abuse.
/// 
/// This implementation uses in-memory storage for rate limiting.
/// For a production app, consider using a persistent storage solution
/// or a dedicated rate limiting service.
class RateLimiter {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _rateLimitPrefix = 'rate_limit_';
  static const _defaultWindow = Duration(minutes: 1);
  
  final Map<String, List<DateTime>> _requestTimestamps = {};
  
  /// Checks if a request is allowed based on the rate limit.
  /// 
  /// [key]: A unique key for the rate limit (e.g., 'login_attempts' or 'api_requests')
  /// [maxRequests]: Maximum number of requests allowed within the time window
  /// [window]: Time window for the rate limit (defaults to 1 minute)
  /// 
  /// Throws [AppException] with 'rate_limit_exceeded' code if the rate limit is exceeded.
  Future<void> checkRateLimit({
    required String key,
    required int maxRequests,
    Duration? window,
  }) async {
    if (maxRequests <= 0) return;
    
    final now = DateTime.now();
    final rateLimitWindow = window ?? _defaultWindow;
    final cacheKey = '$_rateLimitPrefix$key';
    
    // Get the existing timestamps from secure storage
    final timestamps = await _getStoredTimestamps(cacheKey);
    
    // Remove timestamps outside the current window
    final cutoff = now.subtract(rateLimitWindow);
    final recentRequests = timestamps.where((t) => t.isAfter(cutoff)).toList();
    
    // Check if we've exceeded the rate limit
    if (recentRequests.length >= maxRequests) {
      final resetTime = recentRequests.first.add(rateLimitWindow);
      final secondsRemaining = resetTime.difference(now).inSeconds;
      
      throw AppException.rateLimit(
        'Rate limit exceeded. Please try again in $secondsRemaining seconds.',
        retryAfter: secondsRemaining,
      );
    }
    
    // Add the current request timestamp
    recentRequests.add(now);
    
    // Update the stored timestamps
    await _storeTimestamps(cacheKey, recentRequests);
    
    // Update the in-memory cache
    _requestTimestamps[key] = recentRequests;
  }
  
  /// Clears the rate limit for a specific key.
  Future<void> resetRateLimit(String key) async {
    final cacheKey = '$_rateLimitPrefix$key';
    await _storage.delete(key: cacheKey);
    _requestTimestamps.remove(key);
  }
  
  /// Gets the number of requests made within the current window.
  Future<int> getRequestCount(String key, {Duration? window}) async {
    final now = DateTime.now();
    final rateLimitWindow = window ?? _defaultWindow;
    final cacheKey = '$_rateLimitPrefix$key';
    
    // Try to get from memory first
    if (_requestTimestamps.containsKey(key)) {
      final cutoff = now.subtract(rateLimitWindow);
      return _requestTimestamps[key]!
          .where((t) => t.isAfter(cutoff))
          .length;
    }
    
    // Fall back to storage
    final timestamps = await _getStoredTimestamps(cacheKey);
    final cutoff = now.subtract(rateLimitWindow);
    return timestamps.where((t) => t.isAfter(cutoff)).length;
  }
  
  /// Gets the stored timestamps from secure storage.
  Future<List<DateTime>> _getStoredTimestamps(String key) async {
    try {
      final stored = await _storage.read(key: key);
      if (stored == null) return [];
      
      final timestamps = stored.split(',');
      return timestamps
          .where((t) => t.isNotEmpty)
          .map((t) => DateTime.tryParse(t))
          .whereType<DateTime>()
          .toList();
    } catch (e) {
      // If there's an error reading from storage, return an empty list
      return [];
    }
  }
  
  /// Stores the timestamps in secure storage.
  Future<void> _storeTimestamps(String key, List<DateTime> timestamps) async {
    try {
      final serialized = timestamps
          .map((t) => t.toIso8601String())
          .join(',');
      
      await _storage.write(
        key: key,
        value: serialized,
      );
    } catch (e) {
      // If we can't write to storage, we'll just keep it in memory
      // This is a fallback to prevent the app from crashing
    }
  }
}

/// A mixin that provides rate limiting functionality.
mixin RateLimited {
  final RateLimiter _rateLimiter = RateLimiter();
  
  /// Checks if a request is allowed based on the rate limit.
  /// 
  /// [key]: A unique key for the rate limit (e.g., 'login_attempts' or 'api_requests')
  /// [maxRequests]: Maximum number of requests allowed within the time window
  /// [window]: Time window for the rate limit (defaults to 1 minute)
  /// 
  /// Throws [AppException] with 'rate_limit_exceeded' code if the rate limit is exceeded.
  Future<void> checkRateLimit({
    required String key,
    required int maxRequests,
    Duration? window,
  }) async {
    await _rateLimiter.checkRateLimit(
      key: key,
      maxRequests: maxRequests,
      window: window,
    );
  }
  
  /// Clears the rate limit for a specific key.
  Future<void> resetRateLimit(String key) async {
    await _rateLimiter.resetRateLimit(key);
  }
  
  /// Gets the number of requests made within the current window.
  Future<int> getRequestCount(String key, {Duration? window}) async {
    return _rateLimiter.getRequestCount(key, window: window);
  }
}
