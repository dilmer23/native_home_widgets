import 'dart:async';
import 'package:flutter/services.dart';
import '../channels/channel_constants.dart';
import '../models/models.dart';

/// Exposes native widget events as Dart streams.
///
/// Wraps the EventChannel and maps raw maps to typed model objects.
class WidgetEventStream {
  WidgetEventStream({EventChannel? channel})
      : _eventChannel = channel ?? const EventChannel(NativeHomeWidgetsChannels.events);

  final EventChannel _eventChannel;
  StreamSubscription<dynamic>? _subscription;

  final _clickedController = StreamController<WidgetAction>.broadcast();
  final _addedController = StreamController<WidgetInfo>.broadcast();
  final _removedController = StreamController<WidgetInfo>.broadcast();
  final _updatedController = StreamController<WidgetInfo>.broadcast();

  /// Fired when the user taps or clicks a widget.
  Stream<WidgetAction> get onWidgetClicked => _clickedController.stream;

  /// Fired when a widget is added to the home screen.
  Stream<WidgetInfo> get onWidgetAdded => _addedController.stream;

  /// Fired when a widget is removed from the home screen.
  Stream<WidgetInfo> get onWidgetRemoved => _removedController.stream;

  /// Fired when a widget is updated (timeline reloaded, data changed).
  Stream<WidgetInfo> get onWidgetUpdated => _updatedController.stream;

  /// Starts listening to the EventChannel and routing events.
  void start() {
    if (_subscription != null) return;
    _subscription = _eventChannel.receiveBroadcastStream().listen(
      _onEvent,
      onError: _onError,
    );
  }

  void _onEvent(dynamic event) {
    if (event is! Map) return;
    final map = event.cast<String, dynamic>();
    final eventType = map['eventType'] as String?;

    switch (eventType) {
      case NativeHomeWidgetEvents.widgetClicked:
        _clickedController.add(WidgetAction.fromMap(map));
      case NativeHomeWidgetEvents.widgetAdded:
        _addedController.add(WidgetInfo.fromMap(map));
      case NativeHomeWidgetEvents.widgetRemoved:
        _removedController.add(WidgetInfo.fromMap(map));
      case NativeHomeWidgetEvents.widgetUpdated:
        _updatedController.add(WidgetInfo.fromMap(map));
    }
  }

  void _onError(Object error, StackTrace stackTrace) {
    // Errors are swallowed; subscribers only care about valid events.
    // In debug mode, log the error.
    assert(() {
      // ignore: avoid_print
      print('WidgetEventStream error: $error');
      return true;
    }());
  }

  /// Stops listening and closes all stream controllers.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _clickedController.close();
    _addedController.close();
    _removedController.close();
    _updatedController.close();
  }
}
