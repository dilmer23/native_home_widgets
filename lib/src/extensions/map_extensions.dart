/// Extension methods for safe Map access when deserializing platform data.
extension NativeHomeWidgetsMapExtension on Map<String, dynamic> {
  /// Returns the value at [key] cast to [T], or [fallback] if absent/wrong type.
  T? getAs<T>(String key, {T? fallback}) {
    final value = this[key];
    if (value is T) return value;
    return fallback;
  }

  /// Returns the value at [key] cast to [T], throws if absent or wrong type.
  T requireAs<T>(String key) {
    final value = this[key];
    if (value is T) return value;
    throw TypeError();
  }

  /// Parses an int from a value that may be stored as int or String.
  int? getInt(String key) {
    final value = this[key];
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Parses a DateTime from a millisecond timestamp.
  DateTime? getDateTime(String key) {
    final value = this[key];
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return DateTime.fromMillisecondsSinceEpoch(parsed);
    }
    return null;
  }
}
