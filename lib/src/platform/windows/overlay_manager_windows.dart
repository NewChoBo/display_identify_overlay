import 'package:display_identify_overlay/src/models/monitor_info.dart';
import 'package:display_identify_overlay/src/models/overlay_options.dart';
import 'package:display_identify_overlay/src/services/overlay_manager.dart';

/// Windows implementation of [OverlayManager].
class OverlayManagerWindows implements OverlayManager {
  OverlayManagerWindows();

  @override
  Future<void> showOverlays(
    List<MonitorInfo> monitors,
    OverlayOptions options,
  ) async {
    // TODO: Implement Windows overlay creation
    // This will involve creating native windows for each monitor
    // and setting them to always on top
    for (final monitor in monitors) {
      // TODO: Create overlay window for each monitor
    }
  }

  @override
  Future<void> hideAllOverlays() async {
    // TODO: Implement overlay hiding
    // This will involve destroying all created overlay windows
  }
}
