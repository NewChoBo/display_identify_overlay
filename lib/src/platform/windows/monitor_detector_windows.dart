import 'dart:ffi';

import 'package:display_identify_overlay/src/models/monitor_info.dart';
import 'package:display_identify_overlay/src/services/monitor_detector.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart' as win;

/// Windows implementation of [MonitorDetector].
class MonitorDetectorWindows implements MonitorDetector {
  MonitorDetectorWindows();

  @override
  Future<List<MonitorInfo>> getMonitors() async {
    final monitors = <MonitorInfo>[];

    for (int i = 0; ; i++) {
      final dd = calloc<win.DISPLAY_DEVICE>();
      dd.ref.cb = sizeOf<win.DISPLAY_DEVICE>();
      final ok = win.EnumDisplayDevices(nullptr, i, dd, 0);
      if (ok == 0) {
        calloc.free(dd);
        break; // no more devices
      }

      final flags = dd.ref.StateFlags;
      final isActive = (flags & win.DISPLAY_DEVICE_ACTIVE) != 0;
      final attached = (flags & win.DISPLAY_DEVICE_ATTACHED_TO_DESKTOP) != 0;
      if (!attached) {
        calloc.free(dd);
        continue;
      }

      final deviceName = dd.ref.DeviceName;

      final devmode = calloc<win.DEVMODE>();
      devmode.ref.dmSize = sizeOf<win.DEVMODE>();
      final namePtr = win.TEXT(deviceName);
      final ok2 = win.EnumDisplaySettings(
        namePtr,
        win.ENUM_CURRENT_SETTINGS,
        devmode,
      );
      calloc.free(namePtr);

      if (ok2 != 0 && isActive) {
        final pos = devmode.ref.Anonymous1.Anonymous2.dmPosition; // POINTL
        final width = devmode.ref.dmPelsWidth;
        final height = devmode.ref.dmPelsHeight;
        final isPrimary = (flags & win.DISPLAY_DEVICE_PRIMARY_DEVICE) != 0;

        monitors.add(
          MonitorInfo(
            index: monitors.length,
            name: deviceName.isEmpty
                ? 'Monitor ${monitors.length + 1}'
                : deviceName,
            x: pos.x,
            y: pos.y,
            width: width,
            height: height,
            isPrimary: isPrimary,
          ),
        );
      }

      calloc.free(devmode);
      calloc.free(dd);
    }

    // Fallback: virtual screen if none detected
    if (monitors.isEmpty) {
      monitors.add(
        MonitorInfo(
          index: 0,
          name: 'Virtual Screen',
          x: win.GetSystemMetrics(win.SM_XVIRTUALSCREEN),
          y: win.GetSystemMetrics(win.SM_YVIRTUALSCREEN),
          width: win.GetSystemMetrics(win.SM_CXVIRTUALSCREEN),
          height: win.GetSystemMetrics(win.SM_CYVIRTUALSCREEN),
          isPrimary: true,
        ),
      );
    }

    return monitors;
  }
}
