import 'package:rivo_app_beta/core/error_handling/app_exception.dart';

/// A utility class for applying field-level security to API responses.
class FieldSecurity {
  /// Sanitizes a string field to prevent XSS and other injection attacks.
  /// 
  /// [value]: The value to sanitize
  /// [fieldName]: The name of the field for error reporting
  /// [isRequired]: Whether the field is required (default: false)
  /// [maxLength]: Maximum allowed length for the string (default: 500)
  /// 
  /// Returns the sanitized string, or null if the field is not required and empty.
  /// 
  /// Throws [AppException] if:
  /// - The field is required but empty
  /// - The field exceeds the maximum length
  /// - The field contains potentially dangerous content
  static String? sanitizeString({
    required dynamic value,
    required String fieldName,
    bool isRequired = false,
    int maxLength = 500,
  }) {
    // Handle null/empty values
    if (value == null || value.toString().trim().isEmpty) {
      if (isRequired) {
        throw AppException.validation('$fieldName is required');
      }
      return null;
    }

    final strValue = value.toString().trim();

    // Check length
    if (strValue.length > maxLength) {
      throw AppException.validation(
        '$fieldName exceeds maximum length of $maxLength characters',
      );
    }

    // Basic XSS protection - remove script tags and dangerous protocols
    final sanitized = strValue
        .replaceAll(RegExp(r'<script[^>]*>([\s\S]*?)<\/script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'data:', caseSensitive: false), '');

    return sanitized;
  }

  /// Validates and sanitizes a URL field.
  /// 
  /// [value]: The URL to validate and sanitize
  /// [fieldName]: The name of the field for error reporting
  /// [isRequired]: Whether the field is required (default: false)
  /// 
  /// Returns the sanitized URL, or null if the field is not required and empty.
  /// 
  /// Throws [AppException] if:
  /// - The field is required but empty
  /// - The URL is invalid or uses a dangerous protocol
  static String? sanitizeUrl({
    required dynamic value,
    required String fieldName,
    bool isRequired = false,
  }) {
    // Handle null/empty values
    if (value == null || value.toString().trim().isEmpty) {
      if (isRequired) {
        throw AppException.validation('$fieldName is required');
      }
      return null;
    }

    final url = value.toString().trim();
    
    // Basic URL validation
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAbsolutePath) {
      throw AppException.validation('Invalid $fieldName');
    }

    // Only allow http/https protocols
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw AppException.validation('Invalid protocol in $fieldName');
    }

    return url;
  }

  /// Validates and sanitizes a numeric ID field.
  /// 
  /// [value]: The ID to validate
  /// [fieldName]: The name of the field for error reporting
  /// 
  /// Returns the validated ID as a string.
  /// 
  /// Throws [AppException] if the ID is invalid.
  static String validateId(dynamic value, {required String fieldName}) {
    if (value == null) {
      throw AppException.validation('$fieldName is required');
    }

    final id = value.toString().trim();
    
    // Basic UUID validation (adjust regex as needed for your ID format)
    if (!RegExp(r'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\$')
        .hasMatch(id)) {
      throw AppException.validation('Invalid $fieldName format');
    }

    return id;
  }

  /// Validates and sanitizes a list of strings.
  /// 
  /// [value]: The list to validate and sanitize
  /// [fieldName]: The name of the field for error reporting
  /// [maxItems]: Maximum number of items allowed (default: 10)
  /// [maxItemLength]: Maximum length for each item (default: 50)
  /// 
  /// Returns a sanitized list of strings.
  static List<String> sanitizeStringList({
    required dynamic value,
    required String fieldName,
    int maxItems = 10,
    int maxItemLength = 50,
  }) {
    if (value == null) {
      return [];
    }

    if (value is! Iterable) {
      return [];
    }

    final items = value.map((item) => item?.toString().trim() ?? '').toList();

    // Limit number of items
    if (items.length > maxItems) {
      throw AppException.validation(
        '$fieldName cannot contain more than $maxItems items',
      );
    }

    // Process each item
    final result = <String>[];
    for (final item in items) {
      if (item.isNotEmpty) {
        if (item.length > maxItemLength) {
          throw AppException.validation(
            'Item in $fieldName exceeds maximum length of $maxItemLength characters',
          );
        }
        result.add(item);
      }
    }

    return result;
  }
}
