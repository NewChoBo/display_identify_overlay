/// Information about a monitor.
class MonitorInfo {
  /// Creates a [MonitorInfo] with the given parameters.
  const MonitorInfo({
    required this.index,
    required this.name,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.isPrimary,
  });

  /// The monitor index (0-based).
  final int index;

  /// The monitor name/identifier.
  final String name;

  /// The x-coordinate of the monitor's top-left corner.
  final int x;

  /// The y-coordinate of the monitor's top-left corner.
  final int y;

  /// The width of the monitor in pixels.
  final int width;

  /// The height of the monitor in pixels.
  final int height;

  /// Whether this monitor is the primary display.
  final bool isPrimary;

  /// The center x-coordinate of the monitor.
  int get centerX => x + (width ~/ 2);

  /// The center y-coordinate of the monitor.
  int get centerY => y + (height ~/ 2);

  @override
  String toString() =>
      'MonitorInfo(index: $index, name: $name, '
      'position: ($x, $y), size: ${width}x$height, '
      'isPrimary: $isPrimary)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonitorInfo &&
          other.index == index &&
          other.name == name &&
          other.x == x &&
          other.y == y &&
          other.width == width &&
          other.height == height &&
          other.isPrimary == isPrimary;

  @override
  int get hashCode => Object.hash(index, name, x, y, width, height, isPrimary);
}
