import 'package:flutter/material.dart';
import 'package:native_home_widgets/native_home_widgets.dart';

/// A builder widget that prepares content for native home screen widgets.
///
/// Captures its [child] widget tree context (theme, text direction, semantics)
/// and sends layout data to the native platform. The widget itself is invisible
/// in the app's widget tree.
///
/// Supports:
/// - Dark/Light mode via [themeMode]
/// - Material You dynamic colors (Android 12+) via [useMaterialYou]
/// - Accessibility via [semanticLabel]
/// - RTL text direction via [textDirection]
///
/// Example:
/// ```dart
/// HomeWidgetBuilder(
///   widgetId: 'my_widget',
///   themeMode: ThemeMode.system,
///   useMaterialYou: true,
///   semanticLabel: 'Counter widget showing 5 items',
///   child: Column(
///     children: [
///       Text('Hello, Widget!'),
///       Icon(Icons.star),
///     ],
///   ),
/// )
/// ```
class HomeWidgetBuilder extends StatefulWidget {
  const HomeWidgetBuilder({
    super.key,
    required this.child,
    this.widgetId,
    this.themeMode,
    this.useMaterialYou = false,
    this.semanticLabel,
    this.textDirection,
  });

  /// The widget tree to serialize for the native home screen widget.
  final Widget child;

  /// Optional identifier for the target widget.
  final String? widgetId;

  /// The theme mode for the widget (system, light, or dark).
  ///
  /// If null, defaults to the current system brightness.
  final ThemeMode? themeMode;

  /// Whether to use Material You dynamic colors (Android 12+).
  final bool useMaterialYou;

  /// Accessibility label for the widget content.
  final String? semanticLabel;

  /// Text direction override. If null, uses the ambient direction.
  final TextDirection? textDirection;

  @override
  State<HomeWidgetBuilder> createState() => _HomeWidgetBuilderState();
}

class _HomeWidgetBuilderState extends State<HomeWidgetBuilder> {
  @override
  void initState() {
    super.initState();
    _captureAndSend();
  }

  @override
  void didUpdateWidget(HomeWidgetBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child != oldWidget.child ||
        widget.widgetId != oldWidget.widgetId ||
        widget.themeMode != oldWidget.themeMode ||
        widget.useMaterialYou != oldWidget.useMaterialYou ||
        widget.semanticLabel != oldWidget.semanticLabel ||
        widget.textDirection != oldWidget.textDirection) {
      _captureAndSend();
    }
  }

  void _captureAndSend() {
    final brightness = _resolveBrightness();
    final isRtl = widget.textDirection == TextDirection.rtl ||
        (widget.textDirection == null &&
            Directionality.maybeOf(context) == TextDirection.rtl);

    // Send theme configuration to native
    NativeHomeWidgets().saveData(
      key: '_theme_brightness',
      value: brightness.name,
      widgetId: widget.widgetId,
    );
    NativeHomeWidgets().saveData(
      key: '_theme_material_you',
      value: widget.useMaterialYou,
      widgetId: widget.widgetId,
    );
    NativeHomeWidgets().saveData(
      key: '_direction',
      value: isRtl ? 'rtl' : 'ltr',
      widgetId: widget.widgetId,
    );
    if (widget.semanticLabel != null) {
      NativeHomeWidgets().saveData(
        key: '_semantic_label',
        value: widget.semanticLabel,
        widgetId: widget.widgetId,
      );
    }

    // Trigger a widget update to apply theme changes
    NativeHomeWidgets().update(widgetId: widget.widgetId);
  }

  Brightness _resolveBrightness() {
    if (widget.themeMode == ThemeMode.light) return Brightness.light;
    if (widget.themeMode == ThemeMode.dark) return Brightness.dark;
    // Default: follow system
    final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return platformBrightness;
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
