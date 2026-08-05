import 'package:flutter_test/flutter_test.dart';
import 'package:native_home_widgets/native_home_widgets.dart';
import 'package:native_home_widgets/src/platform_interface/native_home_widgets_platform_interface.dart';
import 'package:native_home_widgets/src/platform_interface/method_channel_native_home_widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeHomeWidgetsPlatform
    with MockPlatformInterfaceMixin
    implements NativeHomeWidgetsPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> saveData({required String key, required value, String? widgetId}) =>
      Future.value(true);

  @override
  Future<dynamic> getData({required String key, String? widgetId, defaultValue}) =>
      Future.value('test_value');

  @override
  Future<bool> removeData({required String key, String? widgetId}) =>
      Future.value(true);

  @override
  Future<bool> clearData({String? widgetId}) => Future.value(true);

  @override
  Future<bool> update({String? widgetId}) => Future.value(true);

  @override
  Future<bool> updateAll() => Future.value(true);

  @override
  Future<bool> reloadAll() => Future.value(true);

  @override
  Future<List<WidgetInfo>> getAllWidgets() => Future.value([]);

  @override
  Future<bool> isWidgetInstalled(String widgetId) => Future.value(true);

  @override
  Future<bool> setAccessibility({
    required String widgetId,
    String? label,
    String? hint,
    String? value,
    bool isButton = false,
    bool isHeader = false,
  }) =>
      Future.value(true);

  @override
  Future<bool> saveDeepLink({required String widgetId, required String uri}) =>
      Future.value(true);

  @override
  Future<String?> getDeepLink({required String widgetId}) =>
      Future.value(null);

  @override
  Future<void> openDeepLink({required String widgetId}) =>
      Future.value();

  @override
  Future<bool> pinWidget() => Future.value(true);

  @override
  Future<bool> openConfiguration() => Future.value(true);
}

void main() {
  final NativeHomeWidgetsPlatform initialPlatform = NativeHomeWidgetsPlatform.instance;

  test('$MethodChannelNativeHomeWidgets is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNativeHomeWidgets>());
  });

  test('getPlatformVersion', () async {
    final plugin = NativeHomeWidgets();
    final mockPlatform = MockNativeHomeWidgetsPlatform();
    NativeHomeWidgetsPlatform.instance = mockPlatform;

    expect(await plugin.getPlatformVersion(), '42');
  });

  test('saveData delegates to platform', () async {
    final plugin = NativeHomeWidgets();
    await plugin.saveData(key: 'title', value: 'Hello');
  });

  test('getData returns value from platform', () async {
    final plugin = NativeHomeWidgets();
    final result = await plugin.getData<String>(key: 'title');
    expect(result, 'test_value');
  });

  test('update delegates to platform', () async {
    final plugin = NativeHomeWidgets();
    await plugin.update(widgetId: 'widget_1');
  });

  test('updateAll delegates to platform', () async {
    final plugin = NativeHomeWidgets();
    await plugin.updateAll();
  });

  test('reloadAll delegates to platform', () async {
    final plugin = NativeHomeWidgets();
    await plugin.reloadAll();
  });

  test('pinWidget delegates to platform', () async {
    final plugin = NativeHomeWidgets();
    final result = await plugin.pinWidget();
    expect(result, isTrue);
  });

  test('getInstalledWidgets returns list', () async {
    final plugin = NativeHomeWidgets();
    final result = await plugin.getInstalledWidgets();
    expect(result, isEmpty);
  });

  test('saveData throws on empty key', () async {
    final plugin = NativeHomeWidgets();
    expect(
      () => plugin.saveData(key: '', value: 'test'),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('saveDeepLink delegates to platform', () async {
    final plugin = NativeHomeWidgets();
    await plugin.saveDeepLink(
      widgetId: 'widget_1',
      uri: 'myapp://screen/home',
    );
  });

  test('getDeepLink returns value from platform', () async {
    final plugin = NativeHomeWidgets();
    final result = await plugin.getDeepLink(widgetId: 'widget_1');
    expect(result, isNull);
  });

  test('openDeepLink delegates to platform', () async {
    final plugin = NativeHomeWidgets();
    await plugin.openDeepLink(widgetId: 'widget_1');
  });
}
