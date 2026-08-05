# native_home_widgets

[![pub version](https://img.shields.io/pub/v/native_home_widgets.svg)](https://pub.dev/packages/native_home_widgets)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![stars](https://img.shields.io/github/stars/dilmer23/native_home_widgets?style=social)](https://github.com/dilmer23/native_home_widgets)
[![issues](https://img.shields.io/github/issues/dilmer23/native_home_widgets)](https://github.com/dilmer23/native_home_widgets/issues)

The most complete Flutter plugin for Home Screen Widgets. Create, configure, and manage home screen widgets entirely from Flutter — no native code required.

**Source code:** [github.com/dilmer23/native_home_widgets](https://github.com/dilmer23/native_home_widgets)

## Features

- **Multiple Widget Sizes** — Small, Medium, Large
- **Rich Content** — Progress bars, Battery status, Clock, Weather, Todo lists
- **Interactive Widgets** — Click actions, deep links, open specific screens
- **Theming** — Dark mode, Light mode, Material You (Android 12+)
- **Accessibility** — Semantic labels, hints, RTL support
- **Cross-Platform** — Android (Jetpack Glance) + iOS (WidgetKit + SwiftUI)
- **Type-Safe** — Full Dart models with serialization
- **Event Streams** — React to widget clicks and lifecycle events

## Platform Support

| Platform | Min Version | Framework |
|----------|-------------|-----------|
| Android | API 21 (6.0+) | Jetpack Glance, AppWidgetManager |
| iOS | 16.0+ | WidgetKit, SwiftUI, AppIntents |

## Installation

```yaml
dependencies:
  native_home_widgets: ^0.5.0
```

## Quick Start

```dart
import 'package:native_home_widgets/native_home_widgets.dart';

final widgets = NativeHomeWidgets();

// Save data to be displayed in the widget
await widgets.saveData(
  key: 'title',
  value: 'Hello',
  widgetId: 'my_widget',
);

await widgets.saveData(
  key: 'value',
  value: '42',
  widgetId: 'my_widget',
);

// Trigger widget update
await widgets.update(widgetId: 'my_widget');
```

## API Reference

### Data Operations

```dart
// Save a value (persisted to DataStore on Android, UserDefaults on iOS)
await widgets.saveData(key: 'key', value: 'value', widgetId: 'id');

// Read a value with optional default
final value = await widgets.getData<String>(
  key: 'key',
  widgetId: 'id',
  defaultValue: 'fallback',
);

// Remove a specific value
await widgets.removeData(key: 'key', widgetId: 'id');

// Clear all data for a widget
await widgets.clearData(widgetId: 'id');
```

### Widget Lifecycle

```dart
// Update a specific widget by ID
await widgets.update(widgetId: 'my_widget');

// Update all installed widgets
await widgets.updateAll();

// Force full timeline reload (iOS) / widget recreation (Android)
await widgets.reloadAll();

// Request widget pin to home screen (Android 8+ only)
final success = await widgets.pinWidget();
```

### Deep Links

```dart
// Save a deep link URI for a widget — opens when tapped
await widgets.saveDeepLink(
  widgetId: 'my_widget',
  uri: 'myapp://screen/profile',
);

// Retrieve the stored deep link
final uri = await widgets.getDeepLink(widgetId: 'my_widget');

// Open the deep link programmatically
await widgets.openDeepLink(widgetId: 'my_widget');
```

### Events

```dart
// Start listening to native widget events (call once)
widgets.startListening();

// React to widget taps/clicks
widgets.onWidgetClicked.listen((WidgetAction action) {
  print('Widget ${action.widgetId} clicked: ${action.actionId}');
  // action.target tells you if it should openApp, openScreen, or run in background
});

// React to widget lifecycle
widgets.onWidgetAdded.listen((info) => print('Added: ${info.id}'));
widgets.onWidgetRemoved.listen((info) => print('Removed: ${info.id}'));
widgets.onWidgetUpdated.listen((info) => print('Updated: ${info.id}'));

// Stop listening when done
widgets.stopListening();
```

### Accessibility

```dart
// Configure accessibility for screen readers
await widgets.setAccessibility(
  widgetId: 'my_widget',
  label: 'Shows current temperature',
  value: '72°F',
  hint: 'Tap to refresh',
  isButton: true,
);
```

### Query

```dart
// Get all installed widgets with metadata
final List<WidgetInfo> installed = await widgets.getInstalledWidgets();
for (final info in installed) {
  print('${info.id}: ${info.size} (${info.isInstalled})');
}

// Check if a specific widget is on the home screen
final bool exists = await widgets.isWidgetInstalled('my_widget');
```

## HomeWidgetBuilder

The `HomeWidgetBuilder` captures theme, accessibility, and RTL configuration and sends it to the native platform:

```dart
HomeWidgetBuilder(
  widgetId: 'my_widget',
  themeMode: ThemeMode.system,       // .light, .dark, or .system
  useMaterialYou: true,              // Android 12+ dynamic colors
  semanticLabel: 'Counter showing 5 items',
  textDirection: null,               // Auto-detects from locale
  child: MyWidgetContent(),          // Your widget's visual content
)
```

## Platform Setup

### Android

1. The plugin includes widget receivers and XML metadata out of the box.
2. Ensure your `android/app/src/main/AndroidManifest.xml` has the widget receivers declared.
3. Widget sizes are defined in `res/xml/` (small, medium, large, progress, battery, clock).

### iOS

1. Add a **Widget Extension** target to your Xcode project
2. Add the widget source files from `ios/Classes/widgetkit/` to your extension
3. Configure an **App Group** in both the main app and widget extension targets
4. Add the App Group identifier to your `Info.plist`:

```xml
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
```

5. The plugin uses `UserDefaults(suiteName:)` with your App Group for data sharing.

## Architecture

```
lib/
├── native_home_widgets.dart          # Public API facade + exports
└── src/
    ├── models/                       # Typed data models (WidgetInfo, WidgetTheme, etc.)
    ├── platform_interface/           # Abstract contract + MethodChannel impl
    ├── streams/                      # Event streams (native → Dart)
    ├── builders/                     # HomeWidgetBuilder widget
    ├── services/                     # Serialization, validation
    ├── exceptions/                   # 7 typed exceptions
    ├── channels/                     # Method/event channel constants
    └── extensions/                   # Accessibility, localization helpers

android/src/main/kotlin/.../
├── NativeHomeWidgetsPlugin.kt       # MethodChannel + EventChannel handler
├── data/                            # DataStore persistence, serializer
├── glance/widget/                   # 6 Glance widget definitions
├── interaction/                     # Click receiver, deep links, config activity
└── util/                            # Size resolver, image loader

ios/Classes/
├── NativeHomeWidgetsPlugin.swift    # FlutterPlugin + EventChannel
├── data/                            # UserDefaults + App Groups, serializer
├── widgetkit/widget/                # 6 WidgetKit widget definitions
├── interaction/                     # AppIntents, deep links
└── util/                            # Image loader
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines. Issues and PRs are welcome at [github.com/dilmer23/native_home_widgets](https://github.com/dilmer23/native_home_widgets).

## License

MIT License — see [LICENSE](LICENSE) for details.
