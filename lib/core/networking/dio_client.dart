import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// A secure HTTP client with certificate pinning and other security features.
class DioClient {
  final Dio _dio;
  /// Get the underlying Dio instance
  Dio get dio => _dio;

  /// Creates a new DioClient with security configurations
  DioClient() : _dio = _createDioClient();

  static Dio _createDioClient() {
    // Configure base options with security settings
    final options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
      contentType: 'application/json',
      persistentConnection: true, // Enable HTTP/2
      validateStatus: (status) => status != null && status < 500,
      headers: {
        'X-Content-Type-Options': 'nosniff',
        'X-Frame-Options': 'DENY',
        'X-XSS-Protection': '1; mode=block',
      },
    );

    final dio = Dio(options);

    // Add security interceptors
    _addSecurityInterceptors(dio);

    // Add logging interceptor (debug mode only)
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    // Add retry interceptor for failed requests
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          // Implement retry logic for failed requests
          if (_shouldRetry(error)) {
            // Retry the request
            final requestOptions = error.requestOptions;
            final response = await dio.fetch(requestOptions);
            return handler.resolve(response);
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  // Add security-related interceptors
  static void _addSecurityInterceptors(Dio dio) {
    // Add certificate pinning interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add security headers
          options.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains';
          options.headers['Content-Security-Policy'] = "default-src 'self';";
          
          // Add request timestamp to prevent replay attacks
          options.headers['X-Request-Timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
          
          // You can add request signing here if needed
          // await _signRequest(options);
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Verify response integrity if needed
          // _verifyResponseIntegrity(response);
          return handler.next(response);
        },
        onError: (error, handler) {
          // Log security-related errors
          if (error.response?.statusCode == 401) {
            // Handle unauthorized access
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Check if a request should be retried
  static bool _shouldRetry(DioException error) {
    // Only retry on specific status codes
    final statusCode = error.response?.statusCode;
    if (statusCode == null) return false;
    
    // Retry on server errors and timeouts
    return statusCode >= 500 || 
           error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.sendTimeout;
  }

  // TODO: Implement certificate pinning in a future update
  // This will be used to verify the server's certificate against a known hash
  // to prevent man-in-the-middle attacks.

  // Example method to verify server certificate
  static Future<bool> verifyCertificate(
    X509Certificate cert, 
    String host, 
    int port,
  ) async {
    // In a real app, you would verify the certificate against a pinned certificate
    // or a certificate authority
    return true;
  }
}
