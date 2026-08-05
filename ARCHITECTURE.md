# native_home_widgets — Architecture & Design

## 1. Overview

A production-ready Flutter plugin that lets developers create, configure, and manage Home Screen Widgets entirely from Flutter — without writing native code.

- **Package name:** `native_home_widgets`
- **Dart SDK:** ^3.5.4
- **Flutter:** >=3.3.0
- **Android min SDK:** 23 (Android 6.0)
- **iOS min SDK:** 16.0
- **License:** MIT

## 2. Communication Strategy

### Decision: Method Channels (not Pigeon)

**Why not Pigeon:** Pigeon generates type-safe bindings but adds a codegen step, complicates CI, and makes the barrier to contribution higher. For a plugin that needs to be forked and customized by the community, plain Method Channels are simpler, debuggable, and universally understood.

**Channel layout:**

| Channel | Type | Direction | Purpose |
|---------|------|-----------|---------|
| `native_home_widgets/method` | MethodChannel | Dart → Native | All method calls (save, update, delete, etc.) |
| `native_home_widgets/events` | EventChannel | Native → Dart | Widget click events, lifecycle events |

**Method naming convention:** `snake_case`, namespaced by domain:
- `widget.saveData`
- `widget.update`
- `widget.remove`
- `widget.getAll`
- `widget.reloadAll`
- `widget.pin`
- `widget.openConfiguration`

### Contract: Method arguments & returns

All methods accept `Map<String, dynamic>` arguments and return `Map<String, dynamic>` or primitive. Errors use `PlatformException` with stable error codes (see §7).

## 3. Layered Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App                          │
│  uses NativeHomeWidgets (facade)                        │
└──────────────────────┬──────────────────────────────────┘
                       │ MethodChannel / EventChannel
┌──────────────────────┴──────────────────────────────────┐
│  native_home_widgets (Dart)                             │
│  ┌─────────┐ ┌──────────┐ ┌─────────┐ ┌─────────────┐ │
│  │ Facade  │ │ Models   │ │ Streams │ │ Builders    │ │
│  │ (API)   │ │ (typed)  │ │ (events)│ │ (HomeWidget │ │
│  └────┬────┘ └──────────┘ └────┬────┘ │  Builder)   │ │
│       │                        │       └─────────────┘ │
│  ┌────┴────────────────────────┴─────────────────────┐  │
│  │         Platform Interface                        │  │
│  └────┬────────────────────────┬─────────────────────┘  │
└───────┼────────────────────────┼────────────────────────┘
        │                        │
   ┌────┴─────┐            ┌─────┴────┐
   │ Android  │            │   iOS    │
   │ (Kotlin) │            │  (Swift) │
   └──────────┘            └──────────┘
```

### Layer responsibilities

| Layer | Responsibility |
|-------|---------------|
| **Facade** (`NativeHomeWidgets`) | Single entry point. All public API goes through here. Hides platform interface. |
| **Platform Interface** | Abstract contract. Holds the MethodChannel and EventChannel. |
| **Models** | Immutable typed Dart classes for all data crossing the boundary. |
| **Builders** | `HomeWidgetBuilder` — translates a Flutter widget tree to native widget descriptors. |
| **Streams** | Exposes `onWidgetClicked`, `onWidgetAdded`, `onWidgetRemoved`, `onWidgetUpdated`. |
| **Services** | Internal helpers (serialization, validation, shared prefs on Dart side). |
| **Exceptions** | Typed exceptions with error codes. |
| **Extensions** | Convenience methods on models (`.toMap()`, `.fromMap()`). |

## 4. Folder Structure

```
packages/
└── native_home_widgets/
    ├── lib/
    │   ├── native_home_widgets.dart              # Facade (public API)
    │   ├── src/
    │   │   ├── platform_interface/
    │   │   │   ├── native_home_widgets_platform_interface.dart
    │   │   │   └── method_channel_native_home_widgets.dart
    │   │   ├── models/
    │   │   │   ├── widget_info.dart
    │   │   │   ├── widget_size.dart
    │   │   │   ├── widget_theme.dart
    │   │   │   ├── widget_action.dart
    │   │   │   ├── widget_state.dart
    │   │   │   ├── widget_data.dart
    │   │   │   └── widget_configuration.dart
    │   │   ├── streams/
    │   │   │   └── widget_event_stream.dart
    │   │   ├── builders/
    │   │   │   └── home_widget_builder.dart
    │   │   ├── services/
    │   │   │   ├── serialization_service.dart
    │   │   │   └── validation_service.dart
    │   │   ├── exceptions/
    │   │   │   └── widget_exceptions.dart
    │   │   ├── channels/
    │   │   │   └── channel_constants.dart
    │   │   └── extensions/
    │   │       └── map_extensions.dart
    │   └── native_home_widgets_web.dart           # stub (no-op)
    ├── android/
    │   ├── build.gradle
    │   ├── src/main/
    │   │   ├── AndroidManifest.xml
    │   │   └── kotlin/com/nativehome/native_home_widgets/
    │   │       ├── NativeHomeWidgetsPlugin.kt
    │   │       ├── NativeHomeWidgetsPluginDelegate.kt
    │   │       ├── data/
    │   │       │   ├── WidgetDataStore.kt          # DataStore-backed persistence
    │   │       │   └── WidgetDataSerializer.kt
    │   │       ├── glance/
    │   │       │   ├── GlanceWidgetController.kt
    │   │       │   └── widget/
    │   │       │       ├── SmallWidget.kt
    │   │       │       ├── MediumWidget.kt
    │   │       │       └── LargeWidget.kt
    │   │       ├── interaction/
    │   │       │   ├── WidgetClickReceiver.kt
    │   │       │   └── PendingIntentFactory.kt
    │   │       └── util/
    │   │           ├── AppWidgetSizeResolver.kt
    │   │           └── RemoteImageLoader.kt
    │   └── src/test/kotlin/...                     # unit tests
    ├── ios/
    │   ├── native_home_widgets.podspec
    │   ├── Classes/
    │   │   ├── NativeHomeWidgetsPlugin.swift
    │   │   ├── NativeHomeWidgetsPluginDelegate.swift
    │   │   ├── data/
    │   │   │   ├── WidgetDataStore.swift           # UserDefaults + App Groups
    │   │   │   └── WidgetDataSerializer.swift
    │   │   ├── widgetkit/
    │   │   │   ├── WidgetController.swift
    │   │   │   └── widget/
    │   │   │       ├── SmallWidget.swift
    │   │   │       ├── MediumWidget.swift
    │   │   │       └── LargeWidget.swift
    │   │   ├── interaction/
    │   │   │   └── WidgetIntentHandler.swift
    │   │   └── util/
    │   │       └── RemoteImageLoader.swift
    │   └── Tests/                                  # unit tests
    ├── example/
    │   ├── lib/
    │   │   ├── main.dart
    │   │   └── examples/
    │   │       ├── counter_example.dart
    │   │       ├── todo_example.dart
    │   │       ├── weather_example.dart
    │   │       ├── calendar_example.dart
    │   │       └── interactive_example.dart
    │   └── ...
    ├── test/
    │   ├── unit/
    │   ├── widget/
    │   └── platform/
    ├── pubspec.yaml
    ├── analysis_options.yaml
    ├── README.md
    ├── CHANGELOG.md
    ├── CONTRIBUTING.md
    └── LICENSE
```

## 5. Public API Design

### 5.1 Main facade

```dart
class NativeHomeWidgets {
  static final NativeHomeWidgets _instance = NativeHomeWidgets._();
  factory NativeHomeWidgets() => _instance;

  // ── Data ──────────────────────────────────────────
  Future<void> saveData({
    required String key,
    required dynamic value,
    String? widgetId,
  });

  Future<T?> getData<T>({
    required String key,
    String? widgetId,
    T? defaultValue,
  });

  Future<void> removeData({required String key, String? widgetId});
  Future<void> clearData({String? widgetId});

  // ── Widget lifecycle ──────────────────────────────
  Future<void> update({String? widgetId});
  Future<void> updateAll();
  Future<void> reloadAll();
  Future<bool> pinWidget();

  // ── Query ─────────────────────────────────────────
  Future<List<WidgetInfo>> getInstalledWidgets();
  Future<bool> isWidgetInstalled(String widgetId);

  // ── Configuration ─────────────────────────────────
  Future<void> openConfiguration();

  // ── Events (streams) ──────────────────────────────
  Stream<WidgetAction> get onWidgetClicked;
  Stream<WidgetInfo> get onWidgetAdded;
  Stream<WidgetInfo> get onWidgetRemoved;
  Stream<WidgetInfo> get onWidgetUpdated;
}
```

### 5.2 Models

```dart
class WidgetInfo {
  final String id;
  final WidgetSize size;
  final String? label;
  final bool isInstalled;
  final DateTime? lastUpdated;
}

enum WidgetSize { small, medium, large, extraLarge }

class WidgetTheme {
  final Brightness brightness;
  final ColorScheme? colorScheme;
  final bool useMaterialYou;
}

class WidgetAction {
  final String widgetId;
  final String actionId;
  final Map<String, dynamic> payload;
  final WidgetActionTarget target;
}

enum WidgetActionTarget { openApp, openScreen, background }

class WidgetData {
  final Map<String, dynamic> values;
  final String? widgetId;
  final DateTime? lastModified;
}

class WidgetConfiguration {
  final String widgetId;
  final WidgetSize size;
  final WidgetTheme theme;
  final List<WidgetAction> actions;
  final Map<String, dynamic> data;
}
```

## 6. Platform Communication Contract

### 6.1 Method Channel: `native_home_widgets/method`

| Method | Arguments | Returns | Description |
|--------|-----------|---------|-------------|
| `widget.saveData` | `{key, value, widgetId?}` | `bool` | Persist a value |
| `widget.getData` | `{key, widgetId?, defaultValue?}` | `dynamic` | Read a value |
| `widget.removeData` | `{key, widgetId?}` | `bool` | Delete a value |
| `widget.clearData` | `{widgetId?}` | `bool` | Clear all for widget |
| `widget.update` | `{widgetId?}` | `bool` | Trigger widget reload |
| `widget.updateAll` | `{}` | `bool` | Reload all widgets |
| `widget.reloadAll` | `{}` | `bool` | Force full timeline reload (iOS) |
| `widget.getAll` | `{}` | `List<Map>` | Get all installed widget IDs + sizes |
| `widget.pin` | `{}` | `bool` | Request widget pinning (Android) |
| `widget.openConfiguration` | `{}` | `bool` | Open config activity |
| `widget.getPlatformVersion` | `{}` | `String` | Platform version string |

### 6.2 Event Channel: `native_home_widgets/events`

Events are streamed as `Map<String, dynamic>` with an `eventType` discriminator:

| eventType | payload |
|-----------|---------|
| `widgetClicked` | `{widgetId, actionId, target, payload}` |
| `widgetAdded` | `{widgetId, size, label}` |
| `widgetRemoved` | `{widgetId}` |
| `widgetUpdated` | `{widgetId, timestamp}` |

## 7. Error Handling

### Error codes (cross-platform)

| Code | Meaning |
|------|---------|
| `WIDGET_NOT_FOUND` | Referenced widgetId does not exist |
| `PLATFORM_NOT_SUPPORTED` | Feature not available on this OS version |
| `PERMISSION_DENIED` | App lacks required permission |
| `CONFIGURATION_ERROR` | Widget config is invalid/incomplete |
| `DATA_ERROR` | Serialization/deserialization failure |
| `STORAGE_ERROR` | DataStore / UserDefaults failure |
| `PINNING_FAILED` | System rejected pin request |

### Dart exceptions

```dart
class WidgetNotFoundException implements Exception { ... }
class PlatformNotSupportedException implements Exception { ... }
class PermissionDeniedException implements Exception { ... }
class ConfigurationException implements Exception { ... }
class WidgetDataException implements Exception { ... }
class WidgetStorageException implements Exception { ... }
class WidgetPinningFailedException implements Exception { ... }
```

Mapping from `PlatformException.code` → typed Dart exception happens in the platform interface layer.

## 8. Android Implementation

### Stack
- **Language:** Kotlin 1.9+
- **Min SDK:** 23
- **Compile SDK:** 34 (target 35 when stable)
- **Widget framework:** Jetpack Glance 1.1+ (with AppWidgetManager fallback)
- **Persistence:** DataStore (Preferences)
- **Background work:** WorkManager
- **Async:** Coroutines + Flow
- **Image loading:** Coil (Glance-native)
- **Click handling:** BroadcastReceiver + PendingIntent

### Key components

| Component | Responsibility |
|-----------|---------------|
| `NativeHomeWidgetsPlugin` | MethodChannel handler, delegates to `PluginDelegate` |
| `PluginDelegate` | Routes method calls to services |
| `WidgetDataStore` | DataStore wrapper, keyed by widgetId |
| `GlanceWidgetController` | Creates GlanceAppWidget instances, triggers updates |
| `WidgetClickReceiver` | BroadcastReceiver that captures clicks and forwards via EventChannel |
| `PendingIntentFactory` | Builds PendingIntents for click actions |
| `AppWidgetSizeResolver` | Maps AppWidgetManager options → WidgetSize |
| `RemoteImageLoader` | Coil-based async image loading into Glance |

### Glance widget families
- `SmallWidget` — `SIZE_SMALL` (2×1)
- `MediumWidget` — `SIZE_MEDIUM` (2×2)
- `LargeWidget` — `SIZE_LARGE` (4×2)
- Lock screen widgets handled via `category: KEYGUARD` on compatible families

### Battery considerations
- Use `GlanceAppWidget.updateIf()` to skip unnecessary redraws
- DataStore writes are async and batched by the framework
- WorkManager used for periodic updates with battery-aware constraints

## 9. iOS Implementation

### Stack
- **Language:** Swift 5.9+
- **Min SDK:** 16.0 (support 17+ for interactive widgets)
- **Widget framework:** WidgetKit + SwiftUI
- **Persistence:** UserDefaults (App Groups suite)
- **Interactive widgets:** AppIntents (Button + AppIntent)
- **Timeline:** TimelineProvider with configurable reload policy
- **Image loading:** AsyncImage + URLSession

### Key components

| Component | Responsibility |
|-----------|---------------|
| `NativeHomeWidgetsPlugin` | FlutterPlugin, routes to delegate |
| `PluginDelegate` | Routes method calls |
| `WidgetDataStore` | UserDefaults(suite:) wrapper |
| `WidgetController` | Creates widget configurations, triggers reloads |
| `WidgetIntentHandler` | AppIntents for interactive buttons |
| `RemoteImageLoader` | AsyncImage with caching |

### Widget families
- `SmallWidget` — `.systemSmall`
- `MediumWidget` — `.systemMedium`
- `LargeWidget` — `.systemLarge`
- Lock screen — `.accessoryCircular`, `.accessoryRectangular`, `.accessoryInline` (WidgetKit 2.0 / iOS 16+)

### Interactive widgets (iOS 17+)
- `Button` with `AppIntent` for tap actions
- Intent handled in `WidgetIntentHandler`, posts notification or writes to shared UserDefaults
- Flutter side reads pending actions via stream

## 10. Versioning Strategy

**Semantic Versioning:** `MAJOR.MINOR.PATCH`

| Version | Milestone |
|---------|-----------|
| `0.1.0` | Platform interface + saveData/getData + basic small widget |
| `0.2.0` | All widget sizes, update/reload, getInstalledWidgets |
| `0.3.0` | Click actions, deep links, streams |
| `0.4.0` | Widget configuration, multiple widgets |
| `0.5.0` | Interactive widgets, AppIntents (iOS) |
| `0.6.0` | Lock screen widgets |
| `0.7.0` | Charts, progress, remote images |
| `0.8.0` | HomeWidgetBuilder, rich text, icons |
| `0.9.0` | Polish, examples, documentation |
| `1.0.0` | Stable release |

**Pre-1.0 convention:** Minor bumps = breaking changes, patch = fixes/features.

## 11. Testing Strategy

| Level | Tool | Coverage target |
|-------|------|----------------|
| Unit | `flutter_test` | Models, services, serialization |
| Widget | `flutter_test` | HomeWidgetBuilder, example screens |
| Platform | `mockito` (Android), native mocks (iOS) | MethodChannel routing |
| Integration | `integration_test` | Full save→update→display cycle |

## 12. ADRs

### ADR-001: Method Channels over Pigeon
**Status:** Accepted
**Context:** Need type-safe communication between Dart and native.
**Decision:** Use plain MethodChannels with a typed Dart layer. Pigeon rejected for simplicity.
**Consequence:** Slightly more boilerplate on Dart side, but zero codegen complexity.

### ADR-002: Glance over RemoteViews (Android)
**Status:** Accepted
**Context:** Building home screen widgets on Android.
**Decision:** Primary implementation uses Jetpack Glance; RemoteViews only for lock screen cases Glance doesn't cover.
**Consequence:** Cleaner code, declarative UI, but adds Glance dependency.

### ADR-003: DataStore over SharedPreferences (Android)
**Status:** Accepted
**Context:** Persisting widget data on Android.
**Decision:** DataStore (Preferences) for type safety and async API. SharedPreferences only for backward compat with existing apps.
**Consequence:** Modern API, coroutine-native, but requires kotlin coroutines dependency.

### ADR-004: App Groups for iOS data sharing
**Status:** Accepted
**Context:** Widget and host app must share data on iOS.
**Decision:** Use `UserDefaults(suiteName:)` with an App Group identifier. Configurable via `Info.plist` or Dart API.
**Consequence:** Requires App Group entitlement setup by the developer (documented).

### ADR-005: Single facade pattern
**Status:** Accepted
**Context:** Public API surface.
**Decision:** Single `NativeHomeWidgets` class with static-like access. No builder/factory/callback complexity.
**Consequence:** Easy to discover, easy to mock, simple docs.
