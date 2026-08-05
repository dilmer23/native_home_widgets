import Foundation
import AppIntents

/// Handles interactive widget button actions via AppIntents.
///
/// Interactive widgets (iOS 17+) use `Button` with `AppIntent` for tap actions.
/// The intent performs the action and optionally opens the app via a URL scheme.
///
/// To use interactive widgets, the developer must:
/// 1. Add this intent to their Widget Extension target.
/// 2. Configure a URL scheme for deep linking.
@available(iOS 17.0, *)
struct WidgetButtonIntent: AppIntent {
    static var title: LocalizedStringResource = "Widget Button Action"
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Widget ID")
    var widgetId: String?

    @Parameter(title: "Action ID")
    var actionId: String?

    init() {}

    init(widgetId: String, actionId: String) {
        self.widgetId = widgetId
        self.actionId = actionId
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let wid = widgetId ?? "unknown"
        let aid = actionId ?? "default"

        // Store the click event in shared UserDefaults for the app to read
        let store = WidgetDataStore()
        store.save(key: "last_click_widget", value: wid)
        store.save(key: "last_click_action", value: aid)
        store.save(key: "last_click_timestamp", value: Date().timeIntervalSince1970)

        // Send event to Flutter via EventChannel if app is running
        NativeHomeWidgetsPlugin.sendEvent(
            NativeHomeWidgetsConstants.Events.widgetClicked,
            data: [
                "widgetId": wid,
                "actionId": aid,
                "target": "openApp",
                "payload": [:]
            ]
        )

        return .result()
    }
}

/// AppIntent that opens the app to a specific screen via URL scheme.
@available(iOS 17.0, *)
struct OpenAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Open App"
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Screen")
    var screen: String?

    init() {}

    init(screen: String) {
        self.screen = screen
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
