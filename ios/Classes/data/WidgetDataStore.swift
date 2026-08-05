import Foundation

/// Persistence layer for widget data on iOS.
///
/// Uses `UserDefaults` with an App Group suite to share data between
/// the host app and widget extensions. Falls back to standard
/// `UserDefaults` if no App Group is configured.
class WidgetDataStore {
    private let defaults: UserDefaults

    /// Initializes the data store with an optional App Group identifier.
    ///
    /// - Parameter appGroupId: The App Group suite name. If nil or empty,
    ///   falls back to `UserDefaults.standard`.
    init(appGroupId: String? = nil) {
        if let groupId = appGroupId, !groupId.isEmpty {
            self.defaults = UserDefaults(suiteName: groupId) ?? .standard
        } else {
            self.defaults = UserDefaults(suiteName: NativeHomeWidgetsConstants.defaultAppGroupId) ?? .standard
        }
    }

    /// Saves a value for the given key, optionally scoped to a widget.
    func save(key: String, value: Any, widgetId: String? = nil) {
        let namespacedKey = buildKey(key: key, widgetId: widgetId)
        defaults.set(value, forKey: namespacedKey)
    }

    /// Reads a value by key, returning `defaultValue` if not found.
    func get(key: String, widgetId: String? = nil, defaultValue: Any? = nil) -> Any? {
        let namespacedKey = buildKey(key: key, widgetId: widgetId)
        return defaults.object(forKey: namespacedKey) ?? defaultValue
    }

    /// Removes a specific key.
    func remove(key: String, widgetId: String? = nil) {
        let namespacedKey = buildKey(key: key, widgetId: widgetId)
        defaults.removeObject(forKey: namespacedKey)
    }

    /// Clears all data for a widget, or all data if `widgetId` is nil.
    func clear(widgetId: String? = nil) {
        let allKeys = defaults.dictionaryRepresentation().keys
        if let widgetId = widgetId {
            let prefix = "\(widgetId):"
            allKeys.filter { $0.hasPrefix(prefix) }.forEach {
                defaults.removeObject(forKey: $0)
            }
        } else {
            let prefix = "global:"
            allKeys.filter { $0.hasPrefix(prefix) || $0.contains(":") }.forEach {
                defaults.removeObject(forKey: $0)
            }
        }
    }

    /// Returns all stored entries as a dictionary.
    func getAll() -> [String: Any] {
        return defaults.dictionaryRepresentation()
    }

    private func buildKey(key: String, widgetId: String?) -> String {
        if let widgetId = widgetId {
            return "\(widgetId):\(key)"
        }
        return "global:\(key)"
    }
}
