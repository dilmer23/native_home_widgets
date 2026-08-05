import Foundation

/// Serializes and deserializes widget data for storage and transport.
///
/// On iOS, `UserDefaults` natively supports Property List types, so
/// most types pass through directly. This serializer handles edge cases
/// and ensures cross-platform consistency with the Android implementation.
enum WidgetDataSerializer {

    /// Serializes a value for storage in UserDefaults.
    ///
    /// Property List-compatible types pass through. Other types are
    /// converted to their string representation.
    static func serialize(_ value: Any?) -> Any? {
        guard let value = value else { return nil }

        switch value {
        case is String, is Int, is Double, is Bool, is Data, is Date,
             is [Any], is [String: Any]:
            return value
        default:
            return String(describing: value)
        }
    }

    /// Deserializes a value from storage.
    ///
    /// UserDefaults returns property-list-safe types directly, so
    /// this is mostly a pass-through with type normalization.
    static func deserialize(_ value: Any?) -> Any? {
        return value
    }

    /// Encodes a Date as a TimeInterval (seconds since 1970).
    static func encodeDate(_ date: Date) -> TimeInterval {
        return date.timeIntervalSince1970
    }

    /// Decodes a TimeInterval to a Date.
    static func decodeDate(_ timestamp: TimeInterval) -> Date {
        return Date(timeIntervalSince1970: timestamp)
    }
}
