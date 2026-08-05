/// Validates widget configuration and data before sending to native.
class ValidationService {
  const ValidationService();

  /// Maximum key length for persisted data.
  static const int maxKeyLength = 256;

  /// Maximum serialized value size in bytes.
  static const int maxValueSizeBytes = 64 * 1024; // 64 KB

  /// Validates a storage key.
  static void validateKey(String key) {
    if (key.isEmpty) {
      throw ArgumentError.notNull('key');
    }
    if (key.length > maxKeyLength) {
      throw ArgumentError.value(
        key,
        'key',
        'Key exceeds max length of $maxKeyLength characters',
      );
    }
  }

  /// Validates a widgetId.
  static void validateWidgetId(String? widgetId) {
    if (widgetId == null) return;
    if (widgetId.isEmpty) {
      throw ArgumentError.value(widgetId, 'widgetId', 'Cannot be empty');
    }
    if (widgetId.length > maxKeyLength) {
      throw ArgumentError.value(
        widgetId,
        'widgetId',
        'Exceeds max length of $maxKeyLength characters',
      );
    }
  }

  /// Validates that a serialized value does not exceed size limits.
  static void validateValueSize(dynamic value) {
    if (value is String && value.length * 2 > maxValueSizeBytes) {
      throw ArgumentError.value(
        value,
        'value',
        'Value exceeds max size of $maxValueSizeBytes bytes',
      );
    }
  }
}
