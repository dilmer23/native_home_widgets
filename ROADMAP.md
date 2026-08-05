# Roadmap & Task List

## Phase 0: Foundation (Architecture + Core Dart) ✅
- [x] Architecture document
- [x] Folder structure
- [x] Communication contract
- [x] Create full folder tree
- [x] Define all models with serialization
- [x] Define all exceptions
- [x] Platform interface with all method stubs
- [x] Method channel implementation
- [x] Event channel setup
- [x] Channel constants
- [x] Unit tests for models & serialization (59 tests passing)
- [x] Web stub

## Phase 1: Android Core ✅
- [x] Plugin delegate skeleton
- [x] DataStore persistence layer
- [x] Glance widget (small) — minimal
- [x] Widget update trigger
- [x] Click receiver + PendingIntent
- [x] EventChannel forwarding
- [x] Unit tests
- [x] Remote image loading (Coil)
- [x] Widget size resolver
- [x] Pin widget support
- [x] Configuration activity

## Phase 2: iOS Core ✅
- [ ] Plugin delegate skeleton
- [ ] UserDefaults + App Groups persistence
- [ ] WidgetKit widget (small) — minimal
- [ ] Widget reload trigger
- [ ] AppIntent button handler
- [ ] EventChannel forwarding
- [ ] Unit tests
- [ ] Remote image loading (URLSession)
- [ ] Widget bundle
- [ ] Podspec updated (iOS 16+, WidgetKit/AppIntents)

## Phase 3: Feature Expansion ✅
- [x] Medium + Large widget families (both platforms)
- [x] Multiple widget support (per-widgetId data)
- [x] Deep links + open specific screen
- [x] Widget pin request (Android)
- [x] Widget configuration activity
- [x] Get installed widgets (detailed info with size)
- [x] Widget info XML for all sizes (Android)
- [x] Widget bundle (iOS)

## Phase 4: Rich Content ✅
- [x] Progress indicators (Android + iOS)
- [ ] Rounded images
- [ ] Rich text styling
- [ ] Custom fonts
- [ ] Charts (simple bar/line)
- [x] Battery widget (Android + iOS)
- [x] Clock layouts (Android + iOS)
- [x] Remote image loading (already built in Phase 1/2)

## Phase 5: Builder & Polish ✅
- [x] HomeWidgetBuilder widget (enhanced with theme, accessibility, RTL)
- [x] Dynamic color / Material You (Android 12+)
- [x] Dark Mode / Light Mode support (both platforms)
- [x] RTL support (both platforms)
- [x] Accessibility labels (setAccessibility API + storage)
- [x] Localization helpers (WidgetLocalization)

## Phase 6: Examples ✅
- [x] Counter example
- [x] Todo list example
- [x] Weather example
- [x] Calendar example
- [x] Interactive example
- [x] Main examples home page with navigation
- [x] HomeWidgetBuilder integration in examples
- [x] Public exports for builder, models, exceptions, accessibility

## Phase 7: Documentation & Release ✅
- [x] README.md (comprehensive with API reference, setup, architecture)
- [ ] API docs (dartdoc)
- [x] CONTRIBUTING.md
- [x] CHANGELOG.md
- [x] LICENSE (MIT)
- [x] pubspec.yaml metadata (description, topics, platforms)

---

## Current Status

**Phase 0 in progress.** Architecture approved, now building the Dart layer.
