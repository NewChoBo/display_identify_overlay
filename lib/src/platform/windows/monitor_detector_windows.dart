import 'package:display_identify_overlay/src/models/monitor_info.dart';
import 'package:display_identify_overlay/src/services/monitor_detector.dart';

/// Windows implementation of [MonitorDetector].
class MonitorDetectorWindows implements MonitorDetector {
  MonitorDetectorWindows();

  @override
  Future<List<MonitorInfo>> getMonitors() async {
    // TODO: Implement actual Windows API calls for monitor detection
    // For now, return a simple implementation
    return [
      const MonitorInfo(
        index: 0,
        name: 'Primary Monitor',
        x: 0,
        y: 0,
        width: 1920,
        height: 1080,
        isPrimary: true,
      ),
    ];
  }
}
