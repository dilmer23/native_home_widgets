import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_home_widgets/src/platform_interface/method_channel_native_home_widgets.dart';
import 'package:native_home_widgets/src/channels/channel_constants.dart';
import 'package:native_home_widgets/src/exceptions/widget_exceptions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelNativeHomeWidgets', () {
    late MethodChannelNativeHomeWidgets platform;

    setUp(() {
      platform = MethodChannelNativeHomeWidgets();
    });

    test('uses correct channel name', () {
      expect(NativeHomeWidgetsChannels.method, 'native_home_widgets/method');
    });

    test('channel name matches expected value', () {
      expect(platform.methodChannel.name, 'native_home_widgets/method');
    });

    testWidgets('getPlatformVersion returns mock value', (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        platform.methodChannel,
        (call) async {
          if (call.method == 'getPlatformVersion') return '42';
          return null;
        },
      );

      expect(await platform.getPlatformVersion(), '42');
    });

    testWidgets('saveData invokes correct method', (tester) async {
      String? capturedMethod;
      Map<String, dynamic>? capturedArgs;

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        platform.methodChannel,
        (call) async {
          capturedMethod = call.method;
          capturedArgs = Map<String, dynamic>.from(call.arguments as Map);
          return true;
        },
      );

      await platform.saveData(key: 'title', value: 'Hello');

      expect(capturedMethod, 'widget.saveData');
      expect(capturedArgs?['key'], 'title');
      expect(capturedArgs?['value'], 'Hello');
    });

    testWidgets('getData passes defaultValue', (tester) async {
      String? capturedMethod;
      Map<String, dynamic>? capturedArgs;

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        platform.methodChannel,
        (call) async {
          capturedMethod = call.method;
          capturedArgs = Map<String, dynamic>.from(call.arguments as Map);
          return 'returned_value';
        },
      );

      final result = await platform.getData(
        key: 'title',
        defaultValue: 'fallback',
      );

      expect(capturedMethod, 'widget.getData');
      expect(capturedArgs?['defaultValue'], 'fallback');
      expect(result, 'returned_value');
    });

    testWidgets('PlatformException is mapped to WidgetException', (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        platform.methodChannel,
        (call) async {
          throw PlatformException(
            code: 'WIDGET_NOT_FOUND',
            message: 'Widget not found',
          );
        },
      );

      expect(
        () => platform.getPlatformVersion(),
        throwsA(isA<WidgetNotFoundException>()),
      );
    });
  });
}
