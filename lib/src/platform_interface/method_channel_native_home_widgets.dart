import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../channels/channel_constants.dart';
import '../exceptions/widget_exceptions.dart';
import '../models/models.dart';
import 'native_home_widgets_platform_interface.dart';

/// MethodChannel-based implementation of [NativeHomeWidgetsPlatform].
///
/// Handles serialization of arguments, invocation of native methods,
/// and mapping of PlatformException to typed exceptions.
class MethodChannelNativeHomeWidgets extends NativeHomeWidgetsPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel(NativeHomeWidgetsChannels.method);

  /// Invokes a native method and maps errors to typed exceptions.
  Future<T?> _invoke<T>(String method, [Map<String, dynamic>? args]) async {
    try {
      final result = await methodChannel.invokeMethod<T>(method, args);
      return result;
    } on PlatformException catch (e) {
      throw mapPlatformException(e);
    }
  }

  /// Invokes a native method that must return a non-null value.
  Future<T> _invokeRequired<T>(String method, [Map<String, dynamic>? args]) async {
    final result = await _invoke<T>(method, args);
    if (result == null) {
      throw WidgetStorageException('Native method $method returned null');
    }
    return result;
  }

  @override
  Future<String?> getPlatformVersion() {
    return _invoke<String>(NativeHomeWidgetsMethods.getPlatformVersion);
  }

  @override
  Future<bool> saveData({
    required String key,
    required dynamic value,
    String? widgetId,
  }) async {
    return await _invokeRequired<bool>(
      NativeHomeWidgetsMethods.saveData,
      {
        'key': key,
        'value': value,
        if (widgetId != null) 'widgetId': widgetId,
      },
    );
  }

  @override
  Future<dynamic> getData({
    required String key,
    String? widgetId,
    dynamic defaultValue,
  }) async {
    return await _invoke<dynamic>(
      NativeHomeWidgetsMethods.getData,
      {
        'key': key,
        if (widgetId != null) 'widgetId': widgetId,
        if (defaultValue != null) 'defaultValue': defaultValue,
      },
    ) ?? defaultValue;
  }

  @override
  Future<bool> removeData({required String key, String? widgetId}) async {
    return await _invokeRequired<bool>(
      NativeHomeWidgetsMethods.removeData,
      {
        'key': key,
        if (widgetId != null) 'widgetId': widgetId,
      },
    );
  }

  @override
  Future<bool> clearData({String? widgetId}) async {
    return await _invokeRequired<bool>(
      NativeHomeWidgetsMethods.clearData,
      {
        if (widgetId != null) 'widgetId': widgetId,
      },
    );
  }

  @override
  Future<bool> update({String? widgetId}) async {
    return await _invokeRequired<bool>(
      NativeHomeWidgetsMethods.update,
      {
        if (widgetId != null) 'widgetId': widgetId,
      },
    );
  }

  @override
  Future<bool> updateAll() async {
    return await _invokeRequired<bool>(NativeHomeWidgetsMethods.updateAll);
  }

  @override
  Future<bool> reloadAll() async {
    return await _invokeRequired<bool>(NativeHomeWidgetsMethods.reloadAll);
  }

  @override
  Future<List<WidgetInfo>> getAllWidgets() async {
    final result = await _invoke<List<dynamic>>(
      NativeHomeWidgetsMethods.getAllWidgets,
    );
    if (result == null) return [];
    return result
        .whereType<Map>()
        .map((m) => WidgetInfo.fromMap(m.cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<bool> isWidgetInstalled(String widgetId) async {
    return await _invokeRequired<bool>(
      NativeHomeWidgetsMethods.isWidgetInstalled,
      {'widgetId': widgetId},
    );
  }

  @override
  Future<bool> setAccessibility({
    required String widgetId,
    String? label,
    String? hint,
    String? value,
    bool isButton = false,
    bool isHeader = false,
  }) async {
    return await _invokeRequired<bool>(
      NativeHomeWidgetsMethods.setAccessibility,
      {
        'widgetId': widgetId,
        if (label != null) 'label': label,
        if (hint != null) 'hint': hint,
        if (value != null) 'value': value,
        'isButton': isButton,
        'isHeader': isHeader,
      },
    );
  }

  @override
  Future<bool> saveDeepLink({
    required String widgetId,
    required String uri,
  }) async {
    return await _invokeRequired<bool>(
      NativeHomeWidgetsMethods.saveDeepLink,
      {
        'widgetId': widgetId,
        'uri': uri,
      },
    );
  }

  @override
  Future<String?> getDeepLink({required String widgetId}) async {
    return await _invoke<String?>(
      NativeHomeWidgetsMethods.getDeepLink,
      {'widgetId': widgetId},
    );
  }

  @override
  Future<void> openDeepLink({required String widgetId}) async {
    await _invokeRequired<bool>(
      NativeHomeWidgetsMethods.openDeepLink,
      {'widgetId': widgetId},
    );
  }

  @override
  Future<bool> pinWidget() async {
    return await _invokeRequired<bool>(NativeHomeWidgetsMethods.pinWidget);
  }

  @override
  Future<bool> openConfiguration() async {
    return await _invokeRequired<bool>(
      NativeHomeWidgetsMethods.openConfiguration,
    );
  }
}
