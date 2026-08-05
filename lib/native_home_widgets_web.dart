import '../src/platform_interface/native_home_widgets_platform_interface.dart';
import '../src/models/models.dart';
import '../src/exceptions/widget_exceptions.dart';

/// Web platform stub for native_home_widgets.
///
/// Home screen widgets are not supported on the web.
/// All methods throw [PlatformNotSupportedException].
class NativeHomeWidgetsWeb extends NativeHomeWidgetsPlatform {
  static void registerWith(dynamic registrar) {
    NativeHomeWidgetsPlatform.instance = NativeHomeWidgetsWeb();
  }

  @override
  Future<String?> getPlatformVersion() async => 'Web';

  @override
  Future<bool> saveData({required String key, required value, String? widgetId}) =>
      _unsupported();

  @override
  Future<dynamic> getData({required String key, String? widgetId, defaultValue}) =>
      _unsupported();

  @override
  Future<bool> removeData({required String key, String? widgetId}) => _unsupported();

  @override
  Future<bool> clearData({String? widgetId}) => _unsupported();

  @override
  Future<bool> update({String? widgetId}) => _unsupported();

  @override
  Future<bool> updateAll() => _unsupported();

  @override
  Future<bool> reloadAll() => _unsupported();

  @override
  Future<List<WidgetInfo>> getAllWidgets() async => [];

  @override
  Future<bool> isWidgetInstalled(String widgetId) async => false;

  @override
  Future<bool> pinWidget() => _unsupported();

  @override
  Future<bool> openConfiguration() => _unsupported();

  Never _unsupported() {
    throw const PlatformNotSupportedException(
      'Home screen widgets are not supported on the web',
    );
  }
}
