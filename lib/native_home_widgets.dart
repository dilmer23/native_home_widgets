import 'dart:async';
import '../src/exceptions/widget_exceptions.dart';
import '../src/models/models.dart';
import '../src/platform_interface/native_home_widgets_platform_interface.dart';
import '../src/services/validation_service.dart';
import '../src/streams/widget_event_stream.dart';

// Public exports for consumer convenience
export '../src/models/models.dart';
export '../src/exceptions/widget_exceptions.dart';
export '../src/builders/home_widget_builder.dart';
export '../src/extensions/accessibility.dart';

/// The public API for native_home_widgets.
///
/// Single entry point for all widget operations. All methods validate
/// inputs before delegating to the platform interface.
class NativeHomeWidgets {
  NativeHomeWidgets._();

  static final NativeHomeWidgets _instance = NativeHomeWidgets._();

  /// Returns the singleton instance.
  factory NativeHomeWidgets() => _instance;

  WidgetEventStream? _eventStream;

  /// The platform interface implementation.
  ///
  /// Override this in tests with a mock.
  NativeHomeWidgetsPlatform get platform => NativeHomeWidgetsPlatform.instance;

  // ── Events ──────────────────────────────────────────

  /// Starts listening to native widget events.
  ///
  /// Must be called before accessing event streams.
  void startListening() {
    _eventStream?.dispose();
    _eventStream = WidgetEventStream()..start();
  }

  /// Stops listening to native events and releases resources.
  void stopListening() {
    _eventStream?.dispose();
    _eventStream = null;
  }

  /// Fired when the user taps or clicks a widget.
  Stream<WidgetAction> get onWidgetClicked {
    assert(_eventStream != null, 'Call startListening() first');
    return _eventStream!.onWidgetClicked;
  }

  /// Fired when a widget is added to the home screen.
  Stream<WidgetInfo> get onWidgetAdded {
    assert(_eventStream != null, 'Call startListening() first');
    return _eventStream!.onWidgetAdded;
  }

  /// Fired when a widget is removed from the home screen.
  Stream<WidgetInfo> get onWidgetRemoved {
    assert(_eventStream != null, 'Call startListening() first');
    return _eventStream!.onWidgetRemoved;
  }

  /// Fired when a widget is updated.
  Stream<WidgetInfo> get onWidgetUpdated {
    assert(_eventStream != null, 'Call startListening() first');
    return _eventStream!.onWidgetUpdated;
  }

  // ── Platform info ───────────────────────────────────

  Future<String?> getPlatformVersion() => platform.getPlatformVersion();

  // ── Data ─────────────────────────────────────────────

  /// Persists a key-value pair, optionally scoped to a widget.
  Future<void> saveData({
    required String key,
    required dynamic value,
    String? widgetId,
  }) async {
    ValidationService.validateKey(key);
    ValidationService.validateWidgetId(widgetId);
    ValidationService.validateValueSize(value);
    await platform.saveData(key: key, value: value, widgetId: widgetId);
  }

  /// Reads a persisted value, optionally scoped to a widget.
  Future<T?> getData<T>({
    required String key,
    String? widgetId,
    T? defaultValue,
  }) async {
    ValidationService.validateKey(key);
    ValidationService.validateWidgetId(widgetId);
    final result = await platform.getData(
      key: key,
      widgetId: widgetId,
      defaultValue: defaultValue,
    );
    return result as T?;
  }

  /// Deletes a persisted value.
  Future<void> removeData({required String key, String? widgetId}) async {
    ValidationService.validateKey(key);
    ValidationService.validateWidgetId(widgetId);
    await platform.removeData(key: key, widgetId: widgetId);
  }

  /// Clears all data for a widget (or all widgets if null).
  Future<void> clearData({String? widgetId}) async {
    ValidationService.validateWidgetId(widgetId);
    await platform.clearData(widgetId: widgetId);
  }

  // ── Lifecycle ────────────────────────────────────────

  /// Triggers a reload of a specific widget or all widgets.
  Future<void> update({String? widgetId}) async {
    ValidationService.validateWidgetId(widgetId);
    await platform.update(widgetId: widgetId);
  }

  /// Reloads all installed widgets.
  Future<void> updateAll() => platform.updateAll();

  /// Forces a full timeline reload (iOS) / widget recreation (Android).
  Future<void> reloadAll() => platform.reloadAll();

  // ── Query ────────────────────────────────────────────

  /// Returns information about all installed widgets.
  Future<List<WidgetInfo>> getInstalledWidgets() => platform.getAllWidgets();

  /// Returns true if a widget with [widgetId] is currently installed.
  Future<bool> isWidgetInstalled(String widgetId) async {
    ValidationService.validateWidgetId(widgetId);
    return platform.isWidgetInstalled(widgetId);
  }

  // ── Accessibility ───────────────────────────────────

  /// Sets accessibility configuration for a widget.
  ///
  /// Improves the experience for users with accessibility needs by providing
  /// semantic labels, hints, and traits.
  Future<void> setAccessibility({
    required String widgetId,
    String? label,
    String? hint,
    String? value,
    bool isButton = false,
    bool isHeader = false,
  }) async {
    ValidationService.validateWidgetId(widgetId);
    await platform.setAccessibility(
      widgetId: widgetId,
      label: label,
      hint: hint,
      value: value,
      isButton: isButton,
      isHeader: isHeader,
    );
  }

  // ── Deep Links ───────────────────────────────────────

  /// Saves a deep link URI for a widget. When the widget is clicked,
  /// it will open this URI instead of the default app launcher.
  Future<void> saveDeepLink({
    required String widgetId,
    required String uri,
  }) async {
    ValidationService.validateWidgetId(widgetId);
    await platform.saveDeepLink(widgetId: widgetId, uri: uri);
  }

  /// Returns the stored deep link URI for a widget, or null.
  Future<String?> getDeepLink({required String widgetId}) async {
    ValidationService.validateWidgetId(widgetId);
    return platform.getDeepLink(widgetId: widgetId);
  }

  /// Opens the deep link associated with a widget.
  Future<void> openDeepLink({required String widgetId}) async {
    ValidationService.validateWidgetId(widgetId);
    await platform.openDeepLink(widgetId: widgetId);
  }

  // ── Configuration ───────────────────────────────────

  /// Requests the system to pin a widget to the home screen (Android 8+).
  ///
  /// Throws [PlatformNotSupportedException] on iOS.
  Future<bool> pinWidget() => platform.pinWidget();

  /// Opens the widget configuration screen (Android configuration activity).
  Future<void> openConfiguration() => platform.openConfiguration();
}
