import 'dart:async';
import 'dart:ffi';

import 'package:display_identify_overlay_platform_interface/display_identify_overlay_platform_interface.dart'
    as pi;
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart' as win;

class DisplayIdentifyOverlayWindows
    implements pi.DisplayIdentifyOverlayPlatform {
  DisplayIdentifyOverlayWindows();
  static void registerWith() {
    pi.DisplayIdentifyOverlayPlatform.instance =
        DisplayIdentifyOverlayWindows();
  }

  _WindowsOverlay? _overlay;
  Timer? _autoHideTimer;
  void _onAutoHide() {
    // ignore: discarded_futures
    hideAllOverlays();
  }

  @override
  String get platformName => 'Windows';

  @override
  Future<List<pi.PiMonitorInfo>> getMonitors() async {
    final monitors = <pi.PiMonitorInfo>[];

    for (int i = 0; i < 16; i++) {
      final dd = calloc<win.DISPLAY_DEVICE>();
      dd.ref.cb = sizeOf<win.DISPLAY_DEVICE>();
      final ok = win.EnumDisplayDevices(nullptr, i, dd, 0);
      if (ok == 0) {
        calloc.free(dd);
        break;
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
        final pos = devmode.ref.Anonymous1.Anonymous2.dmPosition;
        final width = devmode.ref.dmPelsWidth;
        final height = devmode.ref.dmPelsHeight;
        final isPrimary = (flags & win.DISPLAY_DEVICE_PRIMARY_DEVICE) != 0;

        monitors.add(
          pi.PiMonitorInfo(
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

    if (monitors.isEmpty) {
      monitors.add(
        pi.PiMonitorInfo(
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

  @override
  Future<void> showOverlays(
    List<pi.PiMonitorInfo> monitors,
    pi.PiOverlayOptions options,
  ) async {
    await hideAllOverlays();

    final overlay = _WindowsOverlay(monitors);
    overlay.initialize();
    _overlay = overlay;

    _autoHideTimer?.cancel();
    if (options.autoHide && options.duration != null) {
      _autoHideTimer = Timer(options.duration!, _onAutoHide);
    }
  }

  @override
  Future<void> hideAllOverlays() async {
    _autoHideTimer?.cancel();
    _autoHideTimer = null;

    final overlay = _overlay;
    if (overlay == null) return;
    overlay.destroyAll();
    _overlay = null;
  }
}

class _WindowsOverlay {
  _WindowsOverlay(this.monitors);

  final List<pi.PiMonitorInfo> monitors;
  final List<int> _hwnds = <int>[];

  late final Pointer<NativeFunction<win.WNDPROC>> _wndProcPtr =
      Pointer.fromFunction<win.WNDPROC>(_wndProc, 0);

  static const _className = 'DIO_OverlayWindowClass';
  static bool _classRegistered = false;

  void initialize() {
    _registerWindowClass();
    for (final m in monitors) {
      _createOverlayForMonitor(m);
    }
  }

  void destroyAll() {
    for (final hwnd in _hwnds) {
      if (hwnd != 0) {
        win.DestroyWindow(hwnd);
      }
    }
    _hwnds.clear();
  }

  void _registerWindowClass() {
    if (_classRegistered) return;
    final hInstance = win.GetModuleHandle(nullptr);
    final wc = calloc<win.WNDCLASSEX>();

    wc.ref.cbSize = sizeOf<win.WNDCLASSEX>();
    wc.ref.style = win.CS_HREDRAW | win.CS_VREDRAW;
    wc.ref.lpfnWndProc = _wndProcPtr;
    wc.ref.cbClsExtra = 0;
    wc.ref.cbWndExtra = 0;
    wc.ref.hInstance = hInstance;
    wc.ref.hIcon = win.LoadIcon(hInstance, win.IDI_APPLICATION);
    wc.ref.hCursor = win.LoadCursor(0, win.IDC_ARROW);
    wc.ref.hbrBackground = win.GetStockObject(win.BLACK_BRUSH);
    wc.ref.lpszMenuName = nullptr;
    final className = win.TEXT(_className);
    wc.ref.lpszClassName = className;
    wc.ref.hIconSm = win.LoadIcon(hInstance, win.IDI_APPLICATION);

    final atom = win.RegisterClassEx(wc);
    calloc.free(className);
    calloc.free(wc);

    _classRegistered = true;
    if (atom == 0) {
      // ok if already registered
    }
  }

  void _createOverlayForMonitor(pi.PiMonitorInfo m) {
    final hInstance = win.GetModuleHandle(nullptr);

    final className = win.TEXT(_className);
    final windowName = win.TEXT('Display Identify ${m.index + 1}');
    final hwnd = win.CreateWindowEx(
      win.WS_EX_TOPMOST |
          win.WS_EX_LAYERED |
          win.WS_EX_TOOLWINDOW |
          win.WS_EX_NOACTIVATE |
          win.WS_EX_TRANSPARENT,
      className,
      windowName,
      win.WS_POPUP,
      m.x,
      m.y,
      m.width,
      m.height,
      0,
      0,
      hInstance,
      nullptr,
    );

    if (hwnd == 0) {
      calloc.free(className);
      calloc.free(windowName);
      final err = win.GetLastError();
      // ignore: avoid_print
      print(
        '[dio_windows] CreateWindowEx failed (${m.index}) GetLastError=$err',
      );
      return;
    }

    win.SetWindowLongPtr(hwnd, win.GWLP_USERDATA, m.index);

    const opacity = 200;
    win.SetLayeredWindowAttributes(hwnd, 0, opacity, win.LWA_ALPHA);

    win.ShowWindow(hwnd, win.SW_SHOWNOACTIVATE);
    // Ensure z-order and visibility
    win.SetWindowPos(
      hwnd,
      win.HWND_TOPMOST,
      0,
      0,
      0,
      0,
      win.SWP_NOMOVE | win.SWP_NOSIZE | win.SWP_NOACTIVATE | win.SWP_SHOWWINDOW,
    );
    // Force immediate paint
    win.UpdateWindow(hwnd);
    win.RedrawWindow(
      hwnd,
      nullptr,
      0,
      win.RDW_INVALIDATE | win.RDW_UPDATENOW | win.RDW_ERASE,
    );

    calloc.free(className);
    calloc.free(windowName);
    _hwnds.add(hwnd);
  }

  static int _wndProc(int hwnd, int uMsg, int wParam, int lParam) {
    switch (uMsg) {
      case win.WM_PAINT:
        _paint(hwnd);
        return 0;
      case win.WM_ERASEBKGND:
        return 1;
      case win.WM_KEYDOWN:
      case win.WM_LBUTTONDOWN:
      case win.WM_RBUTTONDOWN:
      case win.WM_MBUTTONDOWN:
        win.PostMessage(hwnd, win.WM_CLOSE, 0, 0);
        return 0;
      case win.WM_CLOSE:
        win.DestroyWindow(hwnd);
        return 0;
      case win.WM_DESTROY:
        final propName = win.TEXT('DIO_HFONT');
        final hFont = win.GetProp(hwnd, propName);
        if (hFont != 0) {
          win.RemoveProp(hwnd, propName);
          win.DeleteObject(hFont);
        }
        calloc.free(propName);
        return 0;
    }
    return win.DefWindowProc(hwnd, uMsg, wParam, lParam);
  }

  static void _paint(int hwnd) {
    final ps = calloc<win.PAINTSTRUCT>();
    final hdc = win.BeginPaint(hwnd, ps);
    try {
      final rect = calloc<win.RECT>();
      win.GetClientRect(hwnd, rect);

      final brush = win.GetStockObject(win.BLACK_BRUSH);
      win.FillRect(hdc, rect, brush);

      final index = win.GetWindowLongPtr(hwnd, win.GWLP_USERDATA);
      final text = win.TEXT('${index + 1}');

      final height = rect.ref.bottom - rect.ref.top;
      final fontSize = (height * 0.25).clamp(24, 4000).toInt();
      final propName = win.TEXT('DIO_HFONT');
      var hFont = win.GetProp(hwnd, propName);
      if (hFont == 0) {
        final lf = calloc<win.LOGFONT>();
        lf.ref.lfHeight = -fontSize;
        lf.ref.lfWeight = 700;
        hFont = win.CreateFontIndirect(lf);
        win.SetProp(hwnd, propName, hFont);
        calloc.free(lf);
      }
      final oldFont = win.SelectObject(hdc, hFont);

      win.SetBkMode(hdc, win.TRANSPARENT);
      win.SetTextColor(hdc, 0x00FFFFFF);

      win.DrawText(
        hdc,
        text,
        -1,
        rect,
        win.DT_CENTER | win.DT_VCENTER | win.DT_SINGLELINE,
      );

      win.SelectObject(hdc, oldFont);
      calloc.free(propName);
      calloc.free(text);
      calloc.free(rect);
    } finally {
      win.EndPaint(hwnd, ps);
      calloc.free(ps);
    }
  }
}
