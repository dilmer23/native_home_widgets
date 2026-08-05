import 'package:flutter_test/flutter_test.dart';
import 'package:native_home_widgets/src/services/serialization_service.dart';
import 'package:native_home_widgets/src/services/validation_service.dart';
import 'package:native_home_widgets/src/exceptions/widget_exceptions.dart';
import 'package:native_home_widgets/src/extensions/map_extensions.dart';
import 'package:native_home_widgets/src/streams/widget_event_stream.dart';
import 'package:flutter/services.dart';

void main() {
  group('SerializationService', () {
    test('serialize passes through primitives', () {
      expect(SerializationService.serialize('hello'), 'hello');
      expect(SerializationService.serialize(42), 42);
      expect(SerializationService.serialize(3.14), 3.14);
      expect(SerializationService.serialize(true), true);
      expect(SerializationService.serialize(null), null);
    });

    test('serialize converts objects to string', () {
      expect(SerializationService.serialize(DateTime(2024)), isA<String>());
    });

    test('serialize handles nested lists and maps', () {
      final input = {
        'items': [1, 2, 3],
        'nested': {'key': 'value'},
      };
      final result = SerializationService.serialize(input);
      expect(result, isA<Map>());
      expect((result as Map)['items'], [1, 2, 3]);
    });

    test('toJson and fromJson round-trip', () {
      final original = {'key': 'value', 'count': 42};
      final json = SerializationService.toJson(original);
      final restored = SerializationService.fromJson<Map<String, dynamic>>(json);

      expect(restored, original);
    });

    test('fromJson returns null on invalid input', () {
      expect(SerializationService.fromJson<Map>('not json'), isNull);
    });

    test('encodeDateTime / decodeDateTime round-trip', () {
      final dt = DateTime.utc(2024, 1, 15, 12, 30);
      final encoded = SerializationService.encodeDateTime(dt);
      final decoded = SerializationService.decodeDateTime(encoded);

      expect(decoded.year, dt.year);
      expect(decoded.month, dt.month);
      expect(decoded.day, dt.day);
    });
  });

  group('ValidationService', () {
    test('validateKey accepts valid key', () {
      expect(() => ValidationService.validateKey('title'), returnsNormally);
    });

    test('validateKey rejects empty key', () {
      expect(
        () => ValidationService.validateKey(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('validateKey rejects overly long key', () {
      final longKey = 'a' * 300;
      expect(
        () => ValidationService.validateKey(longKey),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('validateWidgetId accepts null', () {
      expect(() => ValidationService.validateWidgetId(null), returnsNormally);
    });

    test('validateWidgetId rejects empty string', () {
      expect(
        () => ValidationService.validateWidgetId(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('validateValueSize accepts small values', () {
      expect(() => ValidationService.validateValueSize('small'), returnsNormally);
    });
  });

  group('WidgetException', () {
    test('WidgetNotFoundException has correct code', () {
      const e = WidgetNotFoundException('Not found');
      expect(e.code, 'WIDGET_NOT_FOUND');
    });

    test('PlatformNotSupportedException has correct code', () {
      const e = PlatformNotSupportedException('Not supported');
      expect(e.code, 'PLATFORM_NOT_SUPPORTED');
    });

    test('ConfigurationException has correct code', () {
      const e = ConfigurationException('Bad config');
      expect(e.code, 'CONFIGURATION_ERROR');
    });

    test('mapPlatformException maps codes correctly', () {
      expect(
        mapPlatformException(
          PlatformException(code: 'WIDGET_NOT_FOUND', message: ''),
        ),
        isA<WidgetNotFoundException>(),
      );
      expect(
        mapPlatformException(
          PlatformException(code: 'PLATFORM_NOT_SUPPORTED', message: ''),
        ),
        isA<PlatformNotSupportedException>(),
      );
      expect(
        mapPlatformException(
          PlatformException(code: 'CONFIGURATION_ERROR', message: ''),
        ),
        isA<ConfigurationException>(),
      );
    });

    test('mapPlatformException returns WidgetStorageException for unknown', () {
      expect(
        mapPlatformException(PlatformException(code: 'UNKNOWN', message: '')),
        isA<WidgetStorageException>(),
      );
    });

    test('mapPlatformException passes through WidgetException', () {
      const original = WidgetNotFoundException('test');
      expect(mapPlatformException(original), same(original));
    });
  });

  group('MapExtensions', () {
    test('getAs returns typed value', () {
      final map = {'key': 'value', 'count': 42};
      expect(map.getAs<String>('key'), 'value');
      expect(map.getAs<int>('count'), 42);
    });

    test('getAs returns fallback for wrong type', () {
      final map = {'key': 'value'};
      expect(map.getAs<int>('key'), isNull);
      expect(map.getAs<int>('key', fallback: 0), 0);
    });

    test('requireAs throws on missing key', () {
      final map = <String, dynamic>{};
      expect(() => map.requireAs<String>('missing'), throwsA(isA<TypeError>()));
    });

    test('getInt parses string numbers', () {
      final map = {'val': '42'};
      expect(map.getInt('val'), 42);
    });

    test('getDateTime parses timestamps', () {
      const ts = 1700000000000;
      final map = {'dt': ts};
      final dt = map.getDateTime('dt');
      expect(dt, isNotNull);
      expect(dt!.millisecondsSinceEpoch, ts);
    });
  });

  group('WidgetEventStream', () {
    test('start and dispose do not throw', () {
      TestWidgetsFlutterBinding.ensureInitialized();
      final stream = WidgetEventStream();
      expect(() {
        stream.start();
        stream.dispose();
      }, returnsNormally);
    });
  });
}
