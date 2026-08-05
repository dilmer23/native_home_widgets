# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.0] - 2026-08-05

### Added
- **Core API** — `NativeHomeWidgets` facade with data, lifecycle, query, deep link, and accessibility methods
- **Models** — `WidgetInfo`, `WidgetSize`, `WidgetTheme`, `WidgetAction`, `WidgetData`, `WidgetConfiguration`, `NativeWidgetState`
- **Platform Interface** — Abstract contract with MethodChannel implementation
- **Event Streams** — `onWidgetClicked`, `onWidgetAdded`, `onWidgetRemoved`, `onWidgetUpdated`
- **Exceptions** — 7 typed exceptions with PlatformException mapping
- **Android** — Jetpack Glance widgets (Small, Medium, Large), DataStore persistence, click receiver, deep links, pin widget
- **iOS** — WidgetKit widgets (Small, Medium, Large), UserDefaults + App Groups, AppIntents, deep links
- **Rich Content** — Progress, Battery, Clock widgets on both platforms
- **HomeWidgetBuilder** — Theme, accessibility, RTL configuration widget
- **Dark Mode** — System theme detection with light/dark color schemes
- **Material You** — Dynamic colors on Android 12+
- **Accessibility** — `setAccessibility` API with label, hint, value, button/header traits
- **RTL Support** — Text direction detection and configuration
- **Localization** — `WidgetLocalization` helper for date/number formatting
- **Examples** — Counter, Todo, Weather, Calendar, Interactive examples
- **Web Stub** — No-op implementation with proper error messages

### Notes
- Initial public release
- 62 unit tests covering models, services, and platform interface
- 6 widget types per platform (Small, Medium, Large, Progress, Battery, Clock)
- Full documentation: README, CONTRIBUTING, ARCHITECTURE, ROADMAP
