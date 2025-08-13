import 'package:display_identify_overlay/src/models/overlay_style.dart';

/// Options for configuring the overlay display.
class OverlayOptions {
  /// Creates an [OverlayOptions] with the given parameters.
  const OverlayOptions({
    this.duration = const Duration(seconds: 3),
    this.style = const OverlayStyle(),
    this.position = OverlayPosition.center,
    this.autoHide = true,
  });

  /// How long to display the overlay. If null, the overlay will stay until manually hidden.
  final Duration? duration;

  /// The style configuration for the overlay.
  final OverlayStyle style;

  /// The position of the overlay on each monitor.
  final OverlayPosition position;

  /// Whether to automatically hide the overlay after the duration.
  final bool autoHide;

  /// Creates a copy of this [OverlayOptions] with the given fields replaced.
  OverlayOptions copyWith({
    Duration? duration,
    OverlayStyle? style,
    OverlayPosition? position,
    bool? autoHide,
  }) => OverlayOptions(
    duration: duration ?? this.duration,
    style: style ?? this.style,
    position: position ?? this.position,
    autoHide: autoHide ?? this.autoHide,
  );

  @override
  String toString() =>
      'OverlayOptions(duration: $duration, style: $style, '
      'position: $position, autoHide: $autoHide)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverlayOptions &&
          other.duration == duration &&
          other.style == style &&
          other.position == position &&
          other.autoHide == autoHide;

  @override
  int get hashCode => Object.hash(duration, style, position, autoHide);
}

/// The position of the overlay on the monitor.
enum OverlayPosition {
  /// Center of the monitor.
  center,

  /// Top-left corner.
  topLeft,

  /// Top-right corner.
  topRight,

  /// Bottom-left corner.
  bottomLeft,

  /// Bottom-right corner.
  bottomRight,

  /// Top center.
  topCenter,

  /// Bottom center.
  bottomCenter,

  /// Left center.
  leftCenter,

  /// Right center.
  rightCenter,
}
