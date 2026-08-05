import Flutter
import UIKit
import WidgetKit

public class NativeHomeWidgetsPlugin: NSObject, FlutterPlugin {
    private static var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: NativeHomeWidgetsConstants.methodChannel,
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: NativeHomeWidgetsConstants.eventChannel,
            binaryMessenger: registrar.messenger()
        )

        let instance = NativeHomeWidgetsPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)

        eventChannel.setStreamHandler(EventStreamHandler())
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let delegate = NativeHomeWidgetsPluginDelegate(result: result)
        delegate.handle(call)
    }

    /// Sends an event from native to Dart via the EventChannel.
    static func sendEvent(_ eventType: String, data: [String: Any]) {
        var payload = data
        payload["eventType"] = eventType
        eventSink?(payload)
    }
}

/// Handles EventChannel stream subscriptions.
class EventStreamHandler: NSObject, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        NativeHomeWidgetsPlugin.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NativeHomeWidgetsPlugin.eventSink = nil
        return nil
    }
}
