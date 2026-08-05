import Foundation
import WidgetKit

/// Routes MethodChannel calls to the appropriate service.
///
/// Each method from the Dart side is dispatched to its handler,
/// which performs the operation and calls the result callback.
class NativeHomeWidgetsPluginDelegate {
    private let result: FlutterResult

    init(result: @escaping FlutterResult) {
        self.result = result
    }

    func handle(_ call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any] else {
            handleMethod(call.method, args: [:])
            return
        }
        handleMethod(call.method, args: args)
    }

    private func handleMethod(_ method: String, args: [String: Any]) {
        switch method {
        case NativeHomeWidgetsConstants.Methods.getPlatformVersion:
            result("iOS " + UIDevice.current.systemVersion)

        // ── Data ────────────────────────────────────────
        case NativeHomeWidgetsConstants.Methods.saveData:
            handleSaveData(args)
        case NativeHomeWidgetsConstants.Methods.getData:
            handleGetData(args)
        case NativeHomeWidgetsConstants.Methods.removeData:
            handleRemoveData(args)
        case NativeHomeWidgetsConstants.Methods.clearData:
            handleClearData(args)

        // ── Lifecycle ───────────────────────────────────
        case NativeHomeWidgetsConstants.Methods.update:
            handleUpdate(args)
        case NativeHomeWidgetsConstants.Methods.updateAll:
            handleUpdateAll()
        case NativeHomeWidgetsConstants.Methods.reloadAll:
            handleReloadAll()

        // ── Query ───────────────────────────────────────
        case NativeHomeWidgetsConstants.Methods.getAllWidgets:
            handleGetAllWidgets()
        case NativeHomeWidgetsConstants.Methods.isWidgetInstalled:
            handleIsInstalled(args)

        // ── Accessibility ───────────────────────────────
        case NativeHomeWidgetsConstants.Methods.setAccessibility:
            handleSetAccessibility(args)

        // ── Deep Links ───────────────────────────────────
        case NativeHomeWidgetsConstants.Methods.saveDeepLink:
            handleSaveDeepLink(args)
        case NativeHomeWidgetsConstants.Methods.getDeepLink:
            handleGetDeepLink(args)
        case NativeHomeWidgetsConstants.Methods.openDeepLink:
            handleOpenDeepLink(args)

        // ── Configuration ───────────────────────────────
        case NativeHomeWidgetsConstants.Methods.pinWidget:
            handlePinWidget()
        case NativeHomeWidgetsConstants.Methods.openConfiguration:
            handleOpenConfiguration()

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // ── Data handlers ─────────────────────────────────────

    private func handleSaveData(_ args: [String: Any]) {
        guard let key = args["key"] as? String else {
            result(FlutterError(code: "DATA_ERROR", message: "Missing key", details: nil))
            return
        }
        let value = args["value"]
        let widgetId = args["widgetId"] as? String

        let store = WidgetDataStore()
        store.save(key: key, value: WidgetDataSerializer.serialize(value), widgetId: widgetId)
        result(true)
    }

    private func handleGetData(_ args: [String: Any]) {
        guard let key = args["key"] as? String else {
            result(FlutterError(code: "DATA_ERROR", message: "Missing key", details: nil))
            return
        }
        let widgetId = args["widgetId"] as? String
        let defaultValue = args["defaultValue"]

        let store = WidgetDataStore()
        let value = store.get(key: key, widgetId: widgetId, defaultValue: defaultValue)
        result(value)
    }

    private func handleRemoveData(_ args: [String: Any]) {
        guard let key = args["key"] as? String else {
            result(FlutterError(code: "DATA_ERROR", message: "Missing key", details: nil))
            return
        }
        let widgetId = args["widgetId"] as? String

        let store = WidgetDataStore()
        store.remove(key: key, widgetId: widgetId)
        result(true)
    }

    private func handleClearData(_ args: [String: Any]) {
        let widgetId = args["widgetId"] as? String

        let store = WidgetDataStore()
        store.clear(widgetId: widgetId)
        result(true)
    }

    // ── Lifecycle handlers ───────────────────────────────

    private func handleUpdate(_ args: [String: Any]) {
        // On iOS, widget updates are triggered via WidgetCenter.
        // The widgetId maps to the widget's kind.
        WidgetController.reloadAllTimelines()
        result(true)
    }

    private func handleUpdateAll() {
        WidgetController.reloadAllTimelines()
        result(true)
    }

    private func handleReloadAll() {
        WidgetController.reloadAllTimelines()
        result(true)
    }

    // ── Query handlers ───────────────────────────────────

    private func handleGetAllWidgets() {
        // iOS does not provide a public API to enumerate all installed widgets.
        // Return an empty list; the developer can track widget IDs via their own logic.
        result([[String: Any]]())
    }

    private func handleIsInstalled(_ args: [String: Any]) {
        // iOS does not expose widget installation status.
        // Always return false; developer should track this themselves.
        result(false)
    }

    // ── Accessibility handlers ─────────────────────────────

    private func handleSetAccessibility(_ args: [String: Any]) {
        guard let widgetId = args["widgetId"] as? String else {
            result(FlutterError(code: "DATA_ERROR", message: "Missing widgetId", details: nil))
            return
        }
        let label = args["label"] as? String
        let hint = args["hint"] as? String
        let value = args["value"] as? String
        let isButton = args["isButton"] as? Bool ?? false
        let isHeader = args["isHeader"] as? Bool ?? false

        let store = WidgetDataStore()
        if let label = label { store.save(key: "_a11y_label", value: label, widgetId: widgetId) }
        if let hint = hint { store.save(key: "_a11y_hint", value: hint, widgetId: widgetId) }
        if let value = value { store.save(key: "_a11y_value", value: value, widgetId: widgetId) }
        store.save(key: "_a11y_isButton", value: isButton, widgetId: widgetId)
        store.save(key: "_a11y_isHeader", value: isHeader, widgetId: widgetId)
        result(true)
    }

    // ── Deep link handlers ─────────────────────────────────

    private func handleSaveDeepLink(_ args: [String: Any]) {
        guard let widgetId = args["widgetId"] as? String else {
            result(FlutterError(code: "DATA_ERROR", message: "Missing widgetId", details: nil))
            return
        }
        guard let uri = args["uri"] as? String else {
            result(FlutterError(code: "DATA_ERROR", message: "Missing uri", details: nil))
            return
        }
        DeepLinkHandler.saveDeepLink(widgetId: widgetId, uri: uri)
        result(true)
    }

    private func handleGetDeepLink(_ args: [String: Any]) {
        guard let widgetId = args["widgetId"] as? String else {
            result(FlutterError(code: "DATA_ERROR", message: "Missing widgetId", details: nil))
            return
        }
        let uri = DeepLinkHandler.getDeepLink(widgetId: widgetId)
        result(uri)
    }

    private func handleOpenDeepLink(_ args: [String: Any]) {
        // On iOS, deep links are typically handled by the app via URL schemes
        // or Universal Links. This method stores the intent for the app to handle.
        guard let widgetId = args["widgetId"] as? String else {
            result(FlutterError(code: "DATA_ERROR", message: "Missing widgetId", details: nil))
            return
        }
        // The app reads the deep link via getDeepLink and handles it.
        result(true)
    }

    // ── Configuration handlers ────────────────────────────

    private func handlePinWidget() {
        // iOS does not support programmatic widget pinning.
        result(FlutterError(
            code: "PLATFORM_NOT_SUPPORTED",
            message: "Widget pinning is not supported on iOS",
            details: nil
        ))
    }

    private func handleOpenConfiguration() {
        // iOS does not have a separate configuration activity.
        // Configuration is handled within the widget itself.
        result(true)
    }
}
