/// Utility for sanitizing all user input before sending to Supabase/SQL.
/// Ensures no malicious or malformed input can reach the database.
class InputSanitizer {
  /// Sanitizes a title: trims, removes control chars, escapes dangerous SQL chars.
  static String sanitizeTitle(String input) {
    return _sanitizeGenericString(input, maxLength: 100);
  }

  /// Sanitizes a description: trims, removes control chars, escapes dangerous SQL chars.
  static String sanitizeDescription(String input) {
    return _sanitizeGenericString(input, maxLength: 1000);
  }

  /// Sanitizes a tag: trims, allows only alphanumeric, Hebrew, spaces, and dashes.
  static String sanitizeTag(String input) {
    final allowed = RegExp(r'^[\u0590-\u05FFa-zA-Z0-9 \-]+');
    final sanitized = input.trim().replaceAll(RegExp(r'[^\u0590-\u05FFa-zA-Z0-9 \-]'), '');
    return allowed.hasMatch(sanitized) ? sanitized : '';
  }

  /// Sanitizes a price: allows only digits and one dot, strips other chars.
  static String sanitizePrice(String input) {
    final sanitized = input.trim().replaceAll(RegExp(r'[^0-9\.]'), '');
    // Only allow one decimal dot
    final parts = sanitized.split('.');
    if (parts.length > 2) {
      return '${parts[0]}.${parts.sublist(1).join('')}';
    }
    return sanitized;
  }

  /// Generic string sanitizer for most fields.
  static String _sanitizeGenericString(String input, {int maxLength = 255}) {
    var sanitized = input.trim();
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ''); // Remove control chars
    sanitized = sanitized.replaceAll("'", ''); // Remove single quotes
    sanitized = sanitized.replaceAll('"', ''); // Remove double quotes
    sanitized = sanitized.replaceAll(';', ''); // Remove semicolons
    sanitized = sanitized.replaceAll('--', ''); // Remove SQL comment
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    return sanitized;
  }

  /// Sanitizes a list of tags.
  static List<String> sanitizeTags(List<String> tags) {
    return tags.map(sanitizeTag).where((t) => t.isNotEmpty).toList();
  }

  /// Sanitizes a size or condition string.
  static String sanitizeSimpleField(String input) {
    return _sanitizeGenericString(input, maxLength: 32);
  }
}
