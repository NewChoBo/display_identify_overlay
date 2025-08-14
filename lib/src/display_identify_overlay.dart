import 'package:display_identify_overlay/src/core/platform_detector.dart';
import 'package:display_identify_overlay/src/exceptions/display_identify_exception.dart';
import 'package:display_identify_overlay/src/models/monitor_info.dart';
import 'package:display_identify_overlay/src/models/overlay_options.dart';
import 'package:display_identify_overlay/src/services/monitor_detector.dart';
import 'package:display_identify_overlay/src/services/overlay_manager.dart';
import 'package:display_identify_overlay_platform_interface/display_identify_overlay_platform_interface.dart'
    as dio_pi;

/// Main API class for displaying monitor identification overlays.
///
/// This class provides a simple interface for showing monitor numbers
/// on all connected displays.
class DisplayIdentifyOverlay {
  DisplayIdentifyOverlay._();

  static final MonitorDetector _monitorDetector = createMonitorDetector();
  static final OverlayManager _overlayManager = OverlayManager();

  static bool get _hasPlugin =>
      dio_pi.DisplayIdentifyOverlayPlatform.instance.platformName !=
      'unsupported';

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
      // Prefer federated plugin path if registered
      if (_hasPlugin) {
        // ignore: avoid_print
        print(
          '[dio] using plugin path; options=${options ?? const OverlayOptions()}',
        );
        final piMonitors = await dio_pi.DisplayIdentifyOverlayPlatform.instance
            .getMonitors();
        if (piMonitors.isEmpty) {
          throw const NoMonitorsDetectedException();
        }
        final opt = options ?? const OverlayOptions();
        final piOptions = dio_pi.PiOverlayOptions(
          duration: opt.duration,
          autoHide: opt.autoHide,
        );
        await dio_pi.DisplayIdentifyOverlayPlatform.instance.showOverlays(
          piMonitors,
          piOptions,
        );
        return;
      }

      // Fallback to legacy services
      // ignore: avoid_print
      print(
        '[dio] using legacy path; options=${options ?? const OverlayOptions()}',
      );
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
    if (_hasPlugin) {
      await dio_pi.DisplayIdentifyOverlayPlatform.instance.hideAllOverlays();
    } else {
      await _overlayManager.hideAllOverlays();
    }
  }

  /// Gets information about all connected monitors.
  ///
  /// Returns a list of [MonitorInfo] objects representing each monitor.
  ///
  /// Throws:
  /// - [UnsupportedPlatformException] if the current platform is not supported
  static Future<List<MonitorInfo>> getMonitors() async {
    if (_hasPlugin) {
      final list = await dio_pi.DisplayIdentifyOverlayPlatform.instance
          .getMonitors();
      return list
          .map(
            (m) => MonitorInfo(
              index: m.index,
              name: m.name,
              x: m.x,
              y: m.y,
              width: m.width,
              height: m.height,
              isPrimary: m.isPrimary,
            ),
          )
          .toList(growable: false);
    }
    return _monitorDetector.getMonitors();
  }

  /// Checks if the current platform is supported.
  ///
  /// Returns true if the platform is supported, false otherwise.
  static bool get isSupported => PlatformDetector.isSupported;

  /// Gets the current platform name.
  static String get platform => PlatformDetector.platform;
}
