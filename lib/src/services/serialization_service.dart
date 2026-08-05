import 'dart:convert';

/// Serializes and deserializes widget data for platform transport.
///
/// Uses JSON as the intermediate format for complex nested data,
/// ensuring both Android (Kotlin) and iOS (Swift) can parse it.
class SerializationService {
  const SerializationService();

  /// Serializes a value to a platform-safe representation.
  ///
  /// Primitives (String, int, double, bool, null) pass through.
  /// Lists and Maps are deep-copied. Everything else becomes a String.
  static dynamic serialize(dynamic value) {
    if (value == null) return null;
    if (value is String || value is int || value is double || value is bool) {
      return value;
    }
    if (value is List) {
      return value.map(serialize).toList();
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), serialize(v)));
    }
    return value.toString();
  }

  /// Serializes a value to a JSON string for complex transport.
  static String toJson(dynamic value) {
    return json.encode(serialize(value));
  }

  /// Deserializes a JSON string back to a Dart value.
  static T? fromJson<T>(String jsonString) {
    try {
      return json.decode(jsonString) as T?;
    } on FormatException {
      return null;
    }
  }

  /// Encodes a DateTime as a UTC millisecond timestamp.
  static int encodeDateTime(DateTime dt) => dt.toUtc().millisecondsSinceEpoch;

  /// Decodes a UTC millisecond timestamp to a local DateTime.
  static DateTime decodeDateTime(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
}
