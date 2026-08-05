import 'package:flutter/widgets.dart';

/// Accessibility configuration for widgets.
///
/// Provides semantic labels, hints, and traits that improve
/// the experience for users with accessibility needs.
@immutable
class WidgetAccessibility {
  const WidgetAccessibility({
    this.label,
    this.hint,
    this.value,
    this.isButton = false,
    this.isHeader = false,
  });

  /// A brief description of the widget's purpose.
  final String? label;

  /// Additional context about what happens when the widget is interacted with.
  final String? hint;

  /// The current value of the widget (e.g., "50% complete").
  final String? value;

  /// Whether the widget should be treated as a button.
  final bool isButton;

  /// Whether the widget content is a heading.
  final bool isHeader;

  /// Converts to a map for sending to the native platform.
  Map<String, dynamic> toMap() => {
    if (label != null) 'label': label,
    if (hint != null) 'hint': hint,
    if (value != null) 'value': value,
    'isButton': isButton,
    'isHeader': isHeader,
  };

  /// Creates a merged configuration, with this instance taking precedence.
  WidgetAccessibility merge(WidgetAccessibility? other) {
    if (other == null) return this;
    return WidgetAccessibility(
      label: label ?? other.label,
      hint: hint ?? other.hint,
      value: value ?? other.value,
      isButton: isButton || other.isButton,
      isHeader: isHeader || other.isHeader,
    );
  }
}

/// Localization helpers for widget content.
///
/// Provides methods for formatting dates, numbers, and text direction
/// based on the widget's locale.
@immutable
class WidgetLocalization {
  const WidgetLocalization({required this.locale});

  final Locale locale;

  /// Returns whether the locale uses right-to-left text direction.
  bool get isRtl {
    const rtlLanguages = {'ar', 'fa', 'he', 'ur', 'yi'};
    return rtlLanguages.contains(locale.languageCode.toLowerCase());
  }

  /// Returns the text direction for the locale.
  TextDirection get textDirection => isRtl ? TextDirection.rtl : TextDirection.ltr;

  /// Formats a number according to the locale.
  String formatNumber(num value) {
    // Use Intl for proper formatting when available.
    // For now, return a simple string representation.
    if (value is int) return value.toString();
    return value.toStringAsFixed(2);
  }

  /// Formats a date according to the locale.
  String formatDate(DateTime date, {String pattern = 'MMM d'}) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Formats time according to the locale.
  String formatTime(DateTime time, {bool use24Hour = true}) {
    final hour = use24Hour ? time.hour : (time.hour % 12 == 0 ? 12 : time.hour % 12);
    final minute = time.minute.toString().padLeft(2, '0');
    if (use24Hour) {
      return '${hour.toString().padLeft(2, '0')}:$minute';
    }
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
