import 'package:flutter/material.dart';
import '../extensions/map_extensions.dart';

/// Sizes a home screen widget can render at.
enum WidgetSize {
  small,
  medium,
  large,
  extraLarge;

  /// Parse from a platform string (e.g., "small", "medium").
  static WidgetSize fromName(String name) {
    return WidgetSize.values.firstWhere(
      (s) => s.name == name,
      orElse: () => WidgetSize.small,
    );
  }
}

/// Information about a widget currently installed on the home screen.
@immutable
class WidgetInfo {
  const WidgetInfo({
    required this.id,
    required this.size,
    this.label,
    this.isInstalled = true,
    this.lastUpdated,
  });

  final String id;
  final WidgetSize size;
  final String? label;
  final bool isInstalled;
  final DateTime? lastUpdated;

  factory WidgetInfo.fromMap(Map<String, dynamic> map) {
    return WidgetInfo(
      id: map.requireAs<String>('id'),
      size: WidgetSize.fromName(map.getAs<String>('size') ?? 'small'),
      label: map.getAs<String>('label'),
      isInstalled: map.getAs<bool>('isInstalled') ?? true,
      lastUpdated: map.getDateTime('lastUpdated'),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'size': size.name,
    if (label != null) 'label': label,
    'isInstalled': isInstalled,
    if (lastUpdated != null) 'lastUpdated': lastUpdated!.millisecondsSinceEpoch,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          size == other.size;

  @override
  int get hashCode => Object.hash(id, size);

  @override
  String toString() => 'WidgetInfo(id: $id, size: $size, installed: $isInstalled)';
}

/// Theme configuration for a widget.
@immutable
class WidgetTheme {
  const WidgetTheme({
    this.brightness = Brightness.light,
    this.colorScheme,
    this.useMaterialYou = false,
  });

  final Brightness brightness;
  final ColorScheme? colorScheme;
  final bool useMaterialYou;

  factory WidgetTheme.fromMap(Map<String, dynamic> map) {
    return WidgetTheme(
      brightness: map.getAs<String>('brightness') == 'dark'
          ? Brightness.dark
          : Brightness.light,
      useMaterialYou: map.getAs<bool>('useMaterialYou') ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'brightness': brightness.name,
    'useMaterialYou': useMaterialYou,
  };
}

/// Where a widget click action should route.
enum WidgetActionTarget {
  openApp,
  openScreen,
  background;

  static WidgetActionTarget fromName(String name) {
    return WidgetActionTarget.values.firstWhere(
      (t) => t.name == name,
      orElse: () => WidgetActionTarget.openApp,
    );
  }
}

/// A user interaction with a widget (click, tap, button press).
@immutable
class WidgetAction {
  const WidgetAction({
    required this.widgetId,
    required this.actionId,
    this.payload = const {},
    this.target = WidgetActionTarget.openApp,
  });

  final String widgetId;
  final String actionId;
  final Map<String, dynamic> payload;
  final WidgetActionTarget target;

  factory WidgetAction.fromMap(Map<String, dynamic> map) {
    return WidgetAction(
      widgetId: map.requireAs<String>('widgetId'),
      actionId: map.requireAs<String>('actionId'),
      payload: (map.getAs<Map>('payload') ?? {})
          .map((k, v) => MapEntry(k.toString(), v)),
      target: WidgetActionTarget.fromName(
        map.getAs<String>('target') ?? 'openApp',
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'widgetId': widgetId,
    'actionId': actionId,
    'payload': payload,
    'target': target.name,
  };
}

/// Current state snapshot of a widget.
@immutable
class NativeWidgetState {
  const NativeWidgetState({
    required this.widgetId,
    required this.isVisible,
    required this.size,
    this.lastRenderedAt,
  });

  final String widgetId;
  final bool isVisible;
  final WidgetSize size;
  final DateTime? lastRenderedAt;

  factory NativeWidgetState.fromMap(Map<String, dynamic> map) {
    return NativeWidgetState(
      widgetId: map.requireAs<String>('widgetId'),
      isVisible: map.getAs<bool>('isVisible') ?? false,
      size: WidgetSize.fromName(map.getAs<String>('size') ?? 'small'),
      lastRenderedAt: map.getDateTime('lastRenderedAt'),
    );
  }
}

/// Arbitrary key-value data associated with a widget.
@immutable
class WidgetData {
  const WidgetData({
    required this.values,
    this.widgetId,
    this.lastModified,
  });

  final Map<String, dynamic> values;
  final String? widgetId;
  final DateTime? lastModified;

  factory WidgetData.fromMap(Map<String, dynamic> map) {
    return WidgetData(
      values: (map.getAs<Map>('values') ?? {})
          .map((k, v) => MapEntry(k.toString(), v)),
      widgetId: map.getAs<String>('widgetId'),
      lastModified: map.getDateTime('lastModified'),
    );
  }

  Map<String, dynamic> toMap() => {
    'values': values,
    if (widgetId != null) 'widgetId': widgetId,
    if (lastModified != null) 'lastModified': lastModified!.millisecondsSinceEpoch,
  };
}

/// Full configuration for creating or updating a widget.
@immutable
class WidgetConfiguration {
  const WidgetConfiguration({
    required this.widgetId,
    this.size = WidgetSize.small,
    this.theme = const WidgetTheme(),
    this.actions = const [],
    this.data = const {},
  });

  final String widgetId;
  final WidgetSize size;
  final WidgetTheme theme;
  final List<WidgetAction> actions;
  final Map<String, dynamic> data;

  factory WidgetConfiguration.fromMap(Map<String, dynamic> map) {
    return WidgetConfiguration(
      widgetId: map.requireAs<String>('widgetId'),
      size: WidgetSize.fromName(map.getAs<String>('size') ?? 'small'),
      theme: map.getAs<Map>('theme') != null
          ? WidgetTheme.fromMap(map.getAs<Map>('theme')!.cast<String, dynamic>())
          : const WidgetTheme(),
      actions: (map.getAs<List>('actions') ?? [])
          .whereType<Map>()
          .map((m) => WidgetAction.fromMap(m.cast<String, dynamic>()))
          .toList(),
      data: (map.getAs<Map>('data') ?? {})
          .map((k, v) => MapEntry(k.toString(), v)),
    );
  }

  Map<String, dynamic> toMap() => {
    'widgetId': widgetId,
    'size': size.name,
    'theme': theme.toMap(),
    'actions': actions.map((a) => a.toMap()).toList(),
    'data': data,
  };

  WidgetConfiguration copyWith({
    String? widgetId,
    WidgetSize? size,
    WidgetTheme? theme,
    List<WidgetAction>? actions,
    Map<String, dynamic>? data,
  }) {
    return WidgetConfiguration(
      widgetId: widgetId ?? this.widgetId,
      size: size ?? this.size,
      theme: theme ?? this.theme,
      actions: actions ?? this.actions,
      data: data ?? this.data,
    );
  }
}
