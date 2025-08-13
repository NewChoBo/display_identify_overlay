import 'package:display_identify_overlay/src/core/platform_detector.dart';
import 'package:display_identify_overlay/src/exceptions/display_identify_exception.dart';
import 'package:display_identify_overlay/src/models/monitor_info.dart';
import 'package:display_identify_overlay/src/platform/windows/monitor_detector_windows.dart';

/// Service for detecting and retrieving information about connected monitors.
abstract class MonitorDetector {
  /// Creates a [MonitorDetector] instance for the current platform.
  factory MonitorDetector() {
    if (PlatformDetector.isWindows) {
      return MonitorDetectorWindows();
    }
    // Graceful no-op detector for unsupported platforms
    return _NoopMonitorDetector();
  }

  /// Gets information about all connected monitors.
  ///
  /// Returns a list of [MonitorInfo] objects representing each monitor.
  ///
  /// Throws:
  /// - [UnsupportedPlatformException] if the current platform is not supported
  Future<List<MonitorInfo>> getMonitors();
}

class _NoopMonitorDetector implements MonitorDetector {
  @override
  Future<List<MonitorInfo>> getMonitors() async => <MonitorInfo>[];
}
