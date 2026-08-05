import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_home_widgets/src/models/models.dart';

void main() {
  group('WidgetSize', () {
    test('fromName parses valid names', () {
      expect(WidgetSize.fromName('small'), WidgetSize.small);
      expect(WidgetSize.fromName('medium'), WidgetSize.medium);
      expect(WidgetSize.fromName('large'), WidgetSize.large);
      expect(WidgetSize.fromName('extraLarge'), WidgetSize.extraLarge);
    });

    test('fromName defaults to small for unknown', () {
      expect(WidgetSize.fromName('unknown'), WidgetSize.small);
    });
  });

  group('WidgetInfo', () {
    test('fromMap parses all fields', () {
      const map = {
        'id': 'widget_1',
        'size': 'medium',
        'label': 'My Widget',
        'isInstalled': true,
        'lastUpdated': 1700000000000,
      };

      final info = WidgetInfo.fromMap(map);

      expect(info.id, 'widget_1');
      expect(info.size, WidgetSize.medium);
      expect(info.label, 'My Widget');
      expect(info.isInstalled, isTrue);
      expect(info.lastUpdated, isNotNull);
    });

    test('fromMap uses defaults for missing fields', () {
      final info = WidgetInfo.fromMap(const {'id': 'w1', 'size': 'small'});

      expect(info.label, isNull);
      expect(info.isInstalled, isTrue);
      expect(info.lastUpdated, isNull);
    });

    test('toMap round-trips correctly', () {
      const info = WidgetInfo(
        id: 'widget_1',
        size: WidgetSize.large,
        label: 'Test',
      );

      final map = info.toMap();
      final restored = WidgetInfo.fromMap(map);

      expect(restored.id, info.id);
      expect(restored.size, info.size);
      expect(restored.label, info.label);
    });

    test('equality is based on id and size', () {
      const a = WidgetInfo(id: 'w1', size: WidgetSize.small);
      const b = WidgetInfo(id: 'w1', size: WidgetSize.small);
      const c = WidgetInfo(id: 'w1', size: WidgetSize.medium);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('WidgetTheme', () {
    test('fromMap parses brightness', () {
      expect(
        WidgetTheme.fromMap(const {'brightness': 'dark'}).brightness,
        Brightness.dark,
      );
      expect(
        WidgetTheme.fromMap(const {'brightness': 'light'}).brightness,
        Brightness.light,
      );
    });

    test('fromMap defaults to light', () {
      expect(WidgetTheme.fromMap(const {}).brightness, Brightness.light);
    });

    test('toMap round-trips', () {
      const theme = WidgetTheme(brightness: Brightness.dark, useMaterialYou: true);
      final restored = WidgetTheme.fromMap(theme.toMap());

      expect(restored.brightness, theme.brightness);
      expect(restored.useMaterialYou, theme.useMaterialYou);
    });
  });

  group('WidgetActionTarget', () {
    test('fromName parses valid targets', () {
      expect(WidgetActionTarget.fromName('openApp'), WidgetActionTarget.openApp);
      expect(WidgetActionTarget.fromName('openScreen'), WidgetActionTarget.openScreen);
      expect(WidgetActionTarget.fromName('background'), WidgetActionTarget.background);
    });

    test('fromName defaults to openApp', () {
      expect(WidgetActionTarget.fromName('unknown'), WidgetActionTarget.openApp);
    });
  });

  group('WidgetAction', () {
    test('fromMap parses all fields', () {
      const map = {
        'widgetId': 'w1',
        'actionId': 'btn_tap',
        'payload': {'screen': 'home'},
        'target': 'openScreen',
      };

      final action = WidgetAction.fromMap(map);

      expect(action.widgetId, 'w1');
      expect(action.actionId, 'btn_tap');
      expect(action.payload, {'screen': 'home'});
      expect(action.target, WidgetActionTarget.openScreen);
    });

    test('toMap round-trips correctly', () {
      const action = WidgetAction(
        widgetId: 'w1',
        actionId: 'tap',
        payload: {'key': 'value'},
        target: WidgetActionTarget.openApp,
      );

      final restored = WidgetAction.fromMap(action.toMap());

      expect(restored.widgetId, action.widgetId);
      expect(restored.actionId, action.actionId);
      expect(restored.payload, action.payload);
      expect(restored.target, action.target);
    });
  });

  group('WidgetData', () {
    test('fromMap parses values', () {
      const map = {
        'values': {'title': 'Hello', 'count': 5},
        'widgetId': 'w1',
        'lastModified': 1700000000000,
      };

      final data = WidgetData.fromMap(map);

      expect(data.values, {'title': 'Hello', 'count': 5});
      expect(data.widgetId, 'w1');
      expect(data.lastModified, isNotNull);
    });

    test('fromMap handles missing values', () {
      final data = WidgetData.fromMap(const {});

      expect(data.values, isEmpty);
      expect(data.widgetId, isNull);
    });
  });

  group('WidgetConfiguration', () {
    test('fromMap parses full configuration', () {
      const map = {
        'widgetId': 'w1',
        'size': 'large',
        'theme': {'brightness': 'dark', 'useMaterialYou': true},
        'actions': [
          {'widgetId': 'w1', 'actionId': 'tap', 'target': 'openApp'},
        ],
        'data': {'title': 'Test'},
      };

      final config = WidgetConfiguration.fromMap(map);

      expect(config.widgetId, 'w1');
      expect(config.size, WidgetSize.large);
      expect(config.theme.brightness, Brightness.dark);
      expect(config.actions, hasLength(1));
      expect(config.data, {'title': 'Test'});
    });

    test('copyWith creates modified copy', () {
      const config = WidgetConfiguration(widgetId: 'w1', size: WidgetSize.small);

      final modified = config.copyWith(size: WidgetSize.large);

      expect(modified.widgetId, 'w1');
      expect(modified.size, WidgetSize.large);
    });

    test('toMap round-trips', () {
      const config = WidgetConfiguration(
        widgetId: 'w1',
        size: WidgetSize.medium,
        data: {'key': 'value'},
      );

      final restored = WidgetConfiguration.fromMap(config.toMap());

      expect(restored.widgetId, config.widgetId);
      expect(restored.size, config.size);
      expect(restored.data, config.data);
    });
  });

  group('NativeWidgetState', () {
    test('fromMap parses correctly', () {
      const map = {
        'widgetId': 'w1',
        'isVisible': true,
        'size': 'small',
        'lastRenderedAt': 1700000000000,
      };

      final state = NativeWidgetState.fromMap(map);

      expect(state.widgetId, 'w1');
      expect(state.isVisible, isTrue);
      expect(state.size, WidgetSize.small);
      expect(state.lastRenderedAt, isNotNull);
    });
  });
}
