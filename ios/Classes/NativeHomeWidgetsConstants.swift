import Foundation

/// Channel and method name constants for native communication.
///
/// Single source of truth shared between Dart and iOS Swift.
enum NativeHomeWidgetsConstants {
    static let methodChannel = "native_home_widgets/method"
    static let eventChannel = "native_home_widgets/events"

    enum Methods {
        static let getPlatformVersion = "getPlatformVersion"

        // Data
        static let saveData = "widget.saveData"
        static let getData = "widget.getData"
        static let removeData = "widget.removeData"
        static let clearData = "widget.clearData"

        // Lifecycle
        static let update = "widget.update"
        static let updateAll = "widget.updateAll"
        static let reloadAll = "widget.reloadAll"

        // Query
        static let getAllWidgets = "widget.getAll"
        static let isWidgetInstalled = "widget.isInstalled"

        // Accessibility
        static let setAccessibility = "widget.setAccessibility"

        // Deep links
        static let saveDeepLink = "widget.saveDeepLink"
        static let getDeepLink = "widget.getDeepLink"
        static let openDeepLink = "widget.openDeepLink"

        // Configuration
        static let pinWidget = "widget.pin"
        static let openConfiguration = "widget.openConfiguration"
    }

    enum Events {
        static let widgetClicked = "widgetClicked"
        static let widgetAdded = "widgetAdded"
        static let widgetRemoved = "widgetRemoved"
        static let widgetUpdated = "widgetUpdated"
    }

    /// Default App Group identifier used for sharing data.
    /// Developers should override this in their Info.plist.
    static let defaultAppGroupId = "group.com.example.nativeHomeWidgets"
}
