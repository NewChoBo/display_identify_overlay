import 'package:display_identify_overlay/src/core/platform_detector.dart';
import 'package:display_identify_overlay/src/exceptions/display_identify_exception.dart';
import 'package:display_identify_overlay/src/models/monitor_info.dart';
import 'package:display_identify_overlay/src/models/overlay_options.dart';
import 'package:display_identify_overlay/src/services/monitor_detector.dart';
import 'package:display_identify_overlay/src/services/overlay_manager.dart';

/// Main API class for displaying monitor identification overlays.
///
/// This class provides a simple interface for showing monitor numbers
/// on all connected displays.
class DisplayIdentifyOverlay {
  DisplayIdentifyOverlay._();

  static final MonitorDetector _monitorDetector = MonitorDetector();
  static final OverlayManager _overlayManager = OverlayManager();

  /// Shows monitor identification numbers on all connected displays.
  ///
  /// [options] - Configuration options for the overlay display.
  ///
  /// Throws:
  /// - [NoMonitorsDetectedException] if no monitors are detected
  /// - [UnsupportedPlatformException] if the current platform is not supported
  /// - [OverlayCreationException] if overlay creation fails
  static Future<void> show([OverlayOptions? options]) async {
    try {
      // If platform unsupported, do nothing to keep API safe on all targets
      if (!PlatformDetector.isSupported) {
        return;
      }
      // Detect monitors
      final monitors = await _monitorDetector.getMonitors();

      if (monitors.isEmpty) {
        throw const NoMonitorsDetectedException();
      }

      // Show overlays on all monitors
      await _overlayManager.showOverlays(
        monitors,
        options ?? const OverlayOptions(),
      );
    } catch (e) {
      if (e is DisplayIdentifyException) {
        rethrow;
      }
      throw OverlayCreationException('Failed to show overlays: $e');
    }
  }

  /// Hides all currently displayed overlays.
  static Future<void> hide() async {
  if (!PlatformDetector.isSupported) return;
    await _overlayManager.hideAllOverlays();
  }

  /// Gets information about all connected monitors.
  ///
  /// Returns a list of [MonitorInfo] objects representing each monitor.
  ///
  /// Throws:
  /// - [UnsupportedPlatformException] if the current platform is not supported
  static Future<List<MonitorInfo>> getMonitors() async =>
  PlatformDetector.isSupported ? _monitorDetector.getMonitors() : <MonitorInfo>[];

  /// Checks if the current platform is supported.
  ///
  /// Returns true if the platform is supported, false otherwise.
  static bool get isSupported => PlatformDetector.isSupported;

  /// Gets the current platform name.
  static String get platform => PlatformDetector.platform;
}
