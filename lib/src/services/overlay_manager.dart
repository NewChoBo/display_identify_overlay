import 'package:display_identify_overlay/src/core/platform_detector.dart';
import 'package:display_identify_overlay/src/models/monitor_info.dart';
import 'package:display_identify_overlay/src/models/overlay_options.dart';
import 'package:display_identify_overlay/src/platform/windows/overlay_manager_windows.dart';

/// Service for managing overlay windows on monitors.
abstract class OverlayManager {
  /// Creates an [OverlayManager] instance for the current platform.
  factory OverlayManager() {
    if (PlatformDetector.isWindows) {
      return OverlayManagerWindows();
    }
    return _NoopOverlayManager();
  }

  /// Shows overlays on all specified monitors.
  ///
  /// [monitors] - List of monitors to show overlays on.
  /// [options] - Configuration options for the overlays.
  ///
  /// Throws:
  /// - OverlayCreationException if overlay creation fails
  Future<void> showOverlays(List<MonitorInfo> monitors, OverlayOptions options);

  /// Hides all currently displayed overlays.
  Future<void> hideAllOverlays();
}

class _NoopOverlayManager implements OverlayManager {
  @override
  Future<void> hideAllOverlays() async {}

  @override
  Future<void> showOverlays(
    List<MonitorInfo> monitors,
    OverlayOptions options,
  ) async {}
}
