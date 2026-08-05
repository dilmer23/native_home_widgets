import Foundation

/// Handles deep links from widget clicks on iOS.
///
/// Stores deep link URIs in shared UserDefaults (App Group) for the app to read.
/// On iOS, deep links are typically handled via URL schemes or Universal Links.
object DeepLinkHandler {

    private let deeplinksKey = "native_home_widgets_deeplinks"

    /// Saves a deep link URI for a specific widget.
    static func saveDeepLink(widgetId: String, uri: String) {
        let store = WidgetDataStore()
        store.save(key: "deeplink", value: uri, widgetId: widgetId)
    }

    /// Returns the stored deep link URI for a widget.
    static func getDeepLink(widgetId: String) -> String? {
        let store = WidgetDataStore()
        return store.get(key: "deeplink", widgetId: widgetId) as? String
    }

    /// Removes a stored deep link for a widget.
    static func removeDeepLink(widgetId: String) {
        let store = WidgetDataStore()
        store.remove(key: "deeplink", widgetId: widgetId)
    }
}
