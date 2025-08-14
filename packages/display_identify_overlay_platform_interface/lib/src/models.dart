import 'package:flutter/foundation.dart';

@immutable
class PiMonitorInfo {
  final int index;
  final String name;
  final int x;
  final int y;
  final int width;
  final int height;
  final bool isPrimary;
  const PiMonitorInfo({
    required this.index,
    required this.name,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.isPrimary,
  });
}

@immutable
class PiOverlayOptions {
  final Duration? duration;
  final bool autoHide;
  const PiOverlayOptions({this.duration, this.autoHide = true});
}
