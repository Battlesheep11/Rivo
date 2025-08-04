import 'package:flutter/widgets.dart';
import 'package:rivo_app_beta/core/error_handling/app_exception.dart';
import 'package:rivo_app_beta/core/localization/generated/app_localizations.dart';
import 'package:uuid/uuid.dart';

/// Validates and sanitizes various types of input data.
class InputValidator {
  /// Validates if a string is a valid UUID v4.
  /// 
  /// Throws [AppException] with 'invalid_id' code if validation fails.
  static String validateId(String id, {String? fieldName = 'ID'}) {
    if (id.isEmpty) {
      throw AppException.validation('$fieldName cannot be empty');
    }
    
    try {
      // This will throw if the ID is not a valid UUID
      Uuid.parse(id);
      return id;
    } catch (e) {
      throw AppException.validation('Invalid $fieldName format');
    }
  }

  /// Validates a list of IDs to ensure they are all valid UUIDs.
  /// 
  /// Throws [AppException] with 'invalid_id' code if any ID is invalid.
  static List<String> validateIdList(List<String> ids, {String? fieldName = 'ID'}) {
    if (ids.isEmpty) {
      return [];
    }
    
    for (final id in ids) {
      validateId(id, fieldName: fieldName);
    }
    
    return ids;
  }

  /// Validates that a string is not empty and meets length requirements.
  /// 
  /// [value]: The string to validate
  /// [fieldName]: The name of the field for error messages
  /// [minLength]: Minimum allowed length (inclusive)
  /// [maxLength]: Maximum allowed length (inclusive)
  /// [allowEmpty]: Whether empty strings are allowed (defaults to false)
  /// 
  /// Returns the trimmed string if validation passes.
  /// Throws [AppException] with 'validation' code if validation fails.
  static String validateString(
    String value, {
    required String fieldName,
    int minLength = 1,
    int? maxLength,
    bool allowEmpty = false,
  }) {
    final trimmed = value.trim();
    
    if (!allowEmpty && trimmed.isEmpty) {
      throw AppException.validation('$fieldName cannot be empty');
    }
    
    if (trimmed.isNotEmpty && trimmed.length < minLength) {
      throw AppException.validation(
        '$fieldName must be at least $minLength characters long',
      );
    }
    
    if (maxLength != null && trimmed.length > maxLength) {
      throw AppException.validation(
        '$fieldName cannot exceed $maxLength characters',
      );
    }
    
    return trimmed;
  }

  /// Sanitizes text input by removing potentially dangerous characters.
  /// 
  /// This is a basic implementation that can be extended based on specific needs.
  /// For production, consider using a dedicated HTML sanitizer if you need to
  /// handle rich text input.
  static String sanitizeText(String input) {
    // Remove any HTML/XML tags
    String sanitized = input.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Remove control characters except newlines, tabs, etc.
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x09\x0B\x0C\x0E-\x1F\x7F]'), '');
    
    return sanitized;
  }

  /// Validates a URL string.
  /// 
  /// Returns the URL if valid, otherwise throws [AppException].
  static String validateUrl(String url, {String? fieldName = 'URL'}) {
    final uri = Uri.tryParse(url);
    
    if (uri == null || !uri.hasAbsolutePath) {
      throw AppException.validation('Invalid $fieldName format');
    }
    
    // Ensure the URL uses HTTPS in production
    if (!uri.isScheme('https') && !uri.isScheme('http')) {
      throw AppException.validation('$fieldName must use HTTP or HTTPS protocol');
    }
    
    return uri.toString();
  }

  /// Validates a numeric value.
  /// 
  /// [value]: The value to validate
  /// [fieldName]: The name of the field for error messages
  /// [min]: Minimum allowed value (inclusive)
  /// [max]: Maximum allowed value (inclusive)
  /// [allowZero]: Whether zero is an allowed value
  /// [allowNegative]: Whether negative numbers are allowed
  /// 
  /// Returns the parsed number if validation passes.
  /// Throws [AppException] with 'validation' code if validation fails.
  static num validateNumber(
    dynamic value, {
    required String fieldName,
    num? min,
    num? max,
    bool allowZero = true,
    bool allowNegative = true,
  }) {
    if (value == null) {
      throw AppException.validation('$fieldName is required');
    }
    
    final number = num.tryParse(value.toString());
    
    if (number == null) {
      throw AppException.validation('$fieldName must be a valid number');
    }
    
    if (!allowZero && number == 0) {
      throw AppException.validation('$fieldName cannot be zero');
    }
    
    if (!allowNegative && number < 0) {
      throw AppException.validation('$fieldName cannot be negative');
    }
    
    if (min != null && number < min) {
      throw AppException.validation('$fieldName must be at least $min');
    }
    
    if (max != null && number > max) {
      throw AppException.validation('$fieldName cannot exceed $max');
    }
    
    return number;
  }
}

/// Extension methods for common validations
extension InputValidatorExtensions on String {
  /// Validates that the string is a non-empty value.
  /// 
  /// Throws [AppException] if validation fails.
  String validateNonEmpty(String fieldName) {
    return InputValidator.validateString(
      this,
      fieldName: fieldName,
      minLength: 1,
    );
  }
  
  /// Validates that the string is a valid email address.
  /// 
  /// Throws [AppException] if validation fails.
  String validateEmail() {
    final email = trim();
    if (email.isEmpty) {
      throw AppException.validation('Email cannot be empty');
    }
    
    // Simple email regex - for production, consider a more comprehensive solution
    final emailRegex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})'
    );
    
    if (!emailRegex.hasMatch(email)) {
      throw AppException.validation('Please enter a valid email address');
    }
    
    return email;
  }
  
  /// Validates that the string is a strong password.
  /// 
  /// Throws [AppException] if validation fails.
  String validatePassword(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isEmpty) {
      throw AppException.validation(l10n.passwordValidationEmpty);
    }

    if (length < 8) {
      throw AppException.validation(l10n.passwordValidationMinLength);
    }

    if (!contains(RegExp(r'[A-Z]'))) {
      throw AppException.validation(l10n.passwordValidationUppercase);
    }

    if (!contains(RegExp(r'[a-z]'))) {
      throw AppException.validation(l10n.passwordValidationLowercase);
    }

    if (!contains(RegExp(r'[0-9]'))) {
      throw AppException.validation(l10n.passwordValidationNumber);
    }

    if (!contains(RegExp(r'[!@#$%^&*(),.?\":{}|<>]'))) {
      throw AppException.validation(l10n.passwordValidationSpecialChar);
    }

    return this;
  }
}
