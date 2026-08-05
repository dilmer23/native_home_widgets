/// Channel and method name constants for native communication.
///
/// Single source of truth for all MethodChannel and EventChannel names
/// and method identifiers used across Dart and native platforms.
class NativeHomeWidgetsChannels {
  NativeHomeWidgetsChannels._();

  /// Method channel: Dart → Native for all method calls.
  static const String method = 'native_home_widgets/method';

  /// Event channel: Native → Dart for widget lifecycle and click events.
  static const String events = 'native_home_widgets/events';
}

/// Method name constants for the MethodChannel.
class NativeHomeWidgetsMethods {
  NativeHomeWidgetsMethods._();

  // Data
  static const String saveData = 'widget.saveData';
  static const String getData = 'widget.getData';
  static const String removeData = 'widget.removeData';
  static const String clearData = 'widget.clearData';

  // Lifecycle
  static const String update = 'widget.update';
  static const String updateAll = 'widget.updateAll';
  static const String reloadAll = 'widget.reloadAll';

  // Query
  static const String getAllWidgets = 'widget.getAll';
  static const String isWidgetInstalled = 'widget.isInstalled';

  // Accessibility
  static const String setAccessibility = 'widget.setAccessibility';

  // Deep links
  static const String saveDeepLink = 'widget.saveDeepLink';
  static const String getDeepLink = 'widget.getDeepLink';
  static const String openDeepLink = 'widget.openDeepLink';

  // Configuration
  static const String pinWidget = 'widget.pin';
  static const String openConfiguration = 'widget.openConfiguration';

  // Platform
  static const String getPlatformVersion = 'getPlatformVersion';
}

/// Event type discriminators for EventChannel events.
class NativeHomeWidgetEvents {
  NativeHomeWidgetEvents._();

  static const String widgetClicked = 'widgetClicked';
  static const String widgetAdded = 'widgetAdded';
  static const String widgetRemoved = 'widgetRemoved';
  static const String widgetUpdated = 'widgetUpdated';
}
