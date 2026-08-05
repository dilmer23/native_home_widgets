import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../models/models.dart';
import 'method_channel_native_home_widgets.dart';

/// The abstract platform interface for native_home_widgets.
///
/// Platform-specific implementations (Android, iOS) must extend this class
/// and override all methods. The default implementation uses MethodChannel.
abstract class NativeHomeWidgetsPlatform extends PlatformInterface {
  NativeHomeWidgetsPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeHomeWidgetsPlatform _instance = MethodChannelNativeHomeWidgets();

  /// The default instance of [NativeHomeWidgetsPlatform] to use.
  static NativeHomeWidgetsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeHomeWidgetsPlatform].
  static set instance(NativeHomeWidgetsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // ── Platform info ───────────────────────────────────

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  // ── Data ─────────────────────────────────────────────

  Future<bool> saveData({
    required String key,
    required dynamic value,
    String? widgetId,
  }) {
    throw UnimplementedError('saveData() has not been implemented.');
  }

  Future<dynamic> getData({
    required String key,
    String? widgetId,
    dynamic defaultValue,
  }) {
    throw UnimplementedError('getData() has not been implemented.');
  }

  Future<bool> removeData({required String key, String? widgetId}) {
    throw UnimplementedError('removeData() has not been implemented.');
  }

  Future<bool> clearData({String? widgetId}) {
    throw UnimplementedError('clearData() has not been implemented.');
  }

  // ── Lifecycle ────────────────────────────────────────

  Future<bool> update({String? widgetId}) {
    throw UnimplementedError('update() has not been implemented.');
  }

  Future<bool> updateAll() {
    throw UnimplementedError('updateAll() has not been implemented.');
  }

  Future<bool> reloadAll() {
    throw UnimplementedError('reloadAll() has not been implemented.');
  }

  // ── Query ────────────────────────────────────────────

  Future<List<WidgetInfo>> getAllWidgets() {
    throw UnimplementedError('getAllWidgets() has not been implemented.');
  }

  Future<bool> isWidgetInstalled(String widgetId) {
    throw UnimplementedError('isWidgetInstalled() has not been implemented.');
  }

  // ── Accessibility ───────────────────────────────────

  Future<bool> setAccessibility({
    required String widgetId,
    String? label,
    String? hint,
    String? value,
    bool isButton = false,
    bool isHeader = false,
  }) {
    throw UnimplementedError('setAccessibility() has not been implemented.');
  }

  // ── Deep Links ───────────────────────────────────────

  Future<bool> saveDeepLink({
    required String widgetId,
    required String uri,
  }) {
    throw UnimplementedError('saveDeepLink() has not been implemented.');
  }

  Future<String?> getDeepLink({required String widgetId}) {
    throw UnimplementedError('getDeepLink() has not been implemented.');
  }

  Future<void> openDeepLink({required String widgetId}) {
    throw UnimplementedError('openDeepLink() has not been implemented.');
  }

  // ── Configuration ───────────────────────────────────

  Future<bool> pinWidget() {
    throw UnimplementedError('pinWidget() has not been implemented.');
  }

  Future<bool> openConfiguration() {
    throw UnimplementedError('openConfiguration() has not been implemented.');
  }
}
