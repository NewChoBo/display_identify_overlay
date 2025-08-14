import 'dart:async';
import 'dart:io';

import 'package:display_identify_overlay_platform_interface/display_identify_overlay_platform_interface.dart'
    as pi;

class DisplayIdentifyOverlayMacOS implements pi.DisplayIdentifyOverlayPlatform {
  DisplayIdentifyOverlayMacOS();
  static void registerWith() {
    if (!Platform.isMacOS) return;
    pi.DisplayIdentifyOverlayPlatform.instance = DisplayIdentifyOverlayMacOS();
  }

  @override
  String get platformName => 'macOS';

  @override
  Future<List<pi.PiMonitorInfo>> getMonitors() async =>
      const <pi.PiMonitorInfo>[
        pi.PiMonitorInfo(
          index: 0,
          name: 'Virtual Screen',
          x: 0,
          y: 0,
          width: 1920,
          height: 1080,
          isPrimary: true,
        ),
      ];

  @override
  Future<void> showOverlays(
    List<pi.PiMonitorInfo> monitors,
    pi.PiOverlayOptions options,
  ) async {}

  @override
  Future<void> hideAllOverlays() async {}
}
