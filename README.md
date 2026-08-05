# native_home_widgets

[![pub version](https://img.shields.io/pub/v/native_home_widgets.svg)](https://pub.dev/packages/native_home_widgets)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![stars](https://img.shields.io/github/stars/dilmer23/native_home_widgets?style=social)](https://github.com/dilmer23/native_home_widgets)

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
// Save a value (persisted to DataStore/UserDefaults)
await widgets.saveData(key: 'key', value: 'value', widgetId: 'id');

// Read a value
final value = await widgets.getData<String>(key: 'key', widgetId: 'id');

// Remove a value
await widgets.removeData(key: 'key', widgetId: 'id');

// Clear all data for a widget
await widgets.clearData(widgetId: 'id');
```

### Widget Lifecycle

```dart
// Update a specific widget
await widgets.update(widgetId: 'my_widget');

// Update all widgets
await widgets.updateAll();

// Force full timeline reload (iOS)
await widgets.reloadAll();

// Request widget pin (Android 8+)
await widgets.pinWidget();
```

### Deep Links

```dart
// Save a deep link for a widget
await widgets.saveDeepLink(
  widgetId: 'my_widget',
  uri: 'myapp://screen/profile',
);

// Open the deep link
await widgets.openDeepLink(widgetId: 'my_widget');
```

### Events

```dart
// Start listening to widget events
widgets.startListening();

// Listen for widget clicks
widgets.onWidgetClicked.listen((action) {
  print('Widget ${action.widgetId} clicked: ${action.actionId}');
});

// Listen for widget added/removed
widgets.onWidgetAdded.listen((info) => print('Added: ${info.id}'));
widgets.onWidgetRemoved.listen((info) => print('Removed: ${info.id}'));
```

### Accessibility

```dart
await widgets.setAccessibility(
  widgetId: 'my_widget',
  label: 'Shows current temperature',
  value: '72°F',
  hint: 'Tap to refresh',
);
```

### Query

```dart
// Get all installed widgets
final installed = await widgets.getInstalledWidgets();

// Check if a specific widget is installed
final isInstalled = await widgets.isWidgetInstalled('my_widget');
```

## HomeWidgetBuilder

The `HomeWidgetBuilder` widget captures theme and accessibility configuration and sends it to the native platform:

```dart
HomeWidgetBuilder(
  widgetId: 'my_widget',
  themeMode: ThemeMode.system,
  useMaterialYou: true,
  semanticLabel: 'Counter showing 5 items',
  child: MyWidgetContent(),
)
```

## Platform Setup

### Android

1. Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<receiver
    android:name=".glance.widget.SmallWidgetReceiver"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/small_widget_info" />
</receiver>
```

### iOS

1. Add a Widget Extension target to your Xcode project
2. Add the widget source files from `ios/Classes/widgetkit/` to your extension
3. Configure an App Group in both targets
4. Add the App Group identifier to your `Info.plist`

## Architecture

```
lib/
├── native_home_widgets.dart          # Public API facade
└── src/
    ├── models/                       # Typed data models
    ├── platform_interface/           # Abstract contract + MethodChannel
    ├── streams/                      # Event streams (native → Dart)
    ├── builders/                     # HomeWidgetBuilder widget
    ├── services/                     # Serialization, validation
    ├── exceptions/                   # Typed exceptions
    ├── channels/                     # Method/event channel constants
    └── extensions/                   # Accessibility, localization

android/src/main/kotlin/.../
├── NativeHomeWidgetsPlugin.kt       # MethodChannel handler
├── data/                            # DataStore persistence
├── glance/widget/                   # Glance widget definitions
├── interaction/                     # Click receiver, deep links
└── util/                            # Size resolver, image loader

ios/Classes/
├── NativeHomeWidgetsPlugin.swift    # FlutterPlugin + EventChannel
├── data/                            # UserDefaults + App Groups
├── widgetkit/widget/                # WidgetKit widget definitions
├── interaction/                     # AppIntents, deep links
└── util/                            # Image loader
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License — see [LICENSE](LICENSE) for details.
