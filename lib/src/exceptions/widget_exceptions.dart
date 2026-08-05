import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Base exception for all native_home_widgets errors.
@immutable
abstract class WidgetException implements Exception {
  const WidgetException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() {
    final codeStr = code != null ? '/$code' : '';
    return '[$runtimeType$codeStr] $message';
  }
}

/// The referenced widget ID does not exist on the device.
class WidgetNotFoundException extends WidgetException {
  const WidgetNotFoundException(super.message, {super.code = 'WIDGET_NOT_FOUND'});
}

/// The feature is not supported on this platform or OS version.
class PlatformNotSupportedException extends WidgetException {
  const PlatformNotSupportedException(super.message, {super.code = 'PLATFORM_NOT_SUPPORTED'});
}

/// The app lacks required permissions to perform the action.
class PermissionDeniedException extends WidgetException {
  const PermissionDeniedException(super.message, {super.code = 'PERMISSION_DENIED'});
}

/// The widget configuration is invalid or incomplete.
class ConfigurationException extends WidgetException {
  const ConfigurationException(super.message, {super.code = 'CONFIGURATION_ERROR'});
}

/// Serialization or deserialization of widget data failed.
class WidgetDataException extends WidgetException {
  const WidgetDataException(super.message, {super.code = 'DATA_ERROR'});
}

/// DataStore / UserDefaults storage operation failed.
class WidgetStorageException extends WidgetException {
  const WidgetStorageException(super.message, {super.code = 'STORAGE_ERROR'});
}

/// The system rejected a widget pin request.
class WidgetPinningFailedException extends WidgetException {
  const WidgetPinningFailedException(super.message, {super.code = 'PINNING_FAILED'});
}

/// Maps a PlatformException to the appropriate typed exception.
WidgetException mapPlatformException(Exception e) {
  if (e is WidgetException) return e;
  if (e is PlatformException) {
    switch (e.code) {
      case 'WIDGET_NOT_FOUND':
        return WidgetNotFoundException(e.message ?? 'Widget not found');
      case 'PLATFORM_NOT_SUPPORTED':
        return PlatformNotSupportedException(e.message ?? 'Feature not supported');
      case 'PERMISSION_DENIED':
        return PermissionDeniedException(e.message ?? 'Permission denied');
      case 'CONFIGURATION_ERROR':
        return ConfigurationException(e.message ?? 'Invalid configuration');
      case 'DATA_ERROR':
        return WidgetDataException(e.message ?? 'Data error');
      case 'STORAGE_ERROR':
        return WidgetStorageException(e.message ?? 'Storage error');
      case 'PINNING_FAILED':
        return WidgetPinningFailedException(e.message ?? 'Pinning failed');
    }
  }
  return WidgetStorageException(e.toString());
}
