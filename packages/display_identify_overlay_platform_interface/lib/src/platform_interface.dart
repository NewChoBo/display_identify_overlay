import 'package:display_identify_overlay_platform_interface/src/models.dart';

abstract class DisplayIdentifyOverlayPlatform {
  static DisplayIdentifyOverlayPlatform? _instance;
  static DisplayIdentifyOverlayPlatform get instance =>
      _instance ??= _DefaultNoop();
  static set instance(DisplayIdentifyOverlayPlatform i) => _instance = i;

  String get platformName;

  Future<List<PiMonitorInfo>> getMonitors();
  Future<void> showOverlays(
    List<PiMonitorInfo> monitors,
    PiOverlayOptions options,
  );
  Future<void> hideAllOverlays();
}

class _DefaultNoop implements DisplayIdentifyOverlayPlatform {
  @override
  String get platformName => 'unsupported';
  @override
  Future<List<PiMonitorInfo>> getMonitors() async => <PiMonitorInfo>[];
  @override
  Future<void> hideAllOverlays() async {}
  @override
  Future<void> showOverlays(
    List<PiMonitorInfo> monitors,
    PiOverlayOptions options,
  ) async {}
}
