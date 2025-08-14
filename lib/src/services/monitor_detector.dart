// ignore_for_file: one_member_abstracts

import 'package:display_identify_overlay/src/core/platform_detector.dart';
import 'package:display_identify_overlay/src/models/monitor_info.dart';
import 'package:display_identify_overlay/src/platform/windows/monitor_detector_windows.dart';

/// Service for detecting and retrieving information about connected monitors.
abstract class MonitorDetector {
  /// Gets information about all connected monitors.
  Future<List<MonitorInfo>> getMonitors();
}

/// Platform-aware factory for [MonitorDetector].
MonitorDetector createMonitorDetector() {
  if (PlatformDetector.isWindows) {
    return MonitorDetectorWindows();
  }
  return _NoopMonitorDetector();
}

class _NoopMonitorDetector implements MonitorDetector {
  @override
  Future<List<MonitorInfo>> getMonitors() async => <MonitorInfo>[];
}
