import 'dart:async';
import 'dart:ffi';

import 'package:display_identify_overlay/src/models/monitor_info.dart';
import 'package:display_identify_overlay/src/models/overlay_options.dart';
import 'package:display_identify_overlay/src/services/overlay_manager.dart';
import 'package:win32/win32.dart' as win;
import 'package:ffi/ffi.dart';

/// Windows implementation of [OverlayManager].
class OverlayManagerWindows implements OverlayManager {
  OverlayManagerWindows();
  _WindowsOverlay? _overlay;
  Timer? _autoHideTimer;

  @override
  Future<void> showOverlays(
    List<MonitorInfo> monitors,
    OverlayOptions options,
  ) async {
    // If already running, hide first to reset state
    await hideAllOverlays();

    final overlay = _WindowsOverlay(monitors, options);
    overlay.initialize();
    _overlay = overlay;

    // Auto-hide if requested
    _autoHideTimer?.cancel();
    if (options.autoHide && options.duration != null) {
      _autoHideTimer = Timer(options.duration!, () {
        hideAllOverlays();
      });
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
  _WindowsOverlay(this.monitors, this.options);

  final List<MonitorInfo> monitors;
  final OverlayOptions options;

  final List<int> _hwnds = <int>[];

  // Window class and proc
  late final Pointer<NativeFunction<win.WNDPROC>> _wndProcPtr =
      Pointer.fromFunction<win.WNDPROC>(_wndProc, 0);

  static const _className = 'DIO_OverlayWindowClass';

  void initialize() {
    _registerWindowClass();
    for (final m in monitors) {
      _createOverlayForMonitor(m);
    }
  }

  void destroyAll() {
    for (final hwnd in _hwnds) {
      // Destroy synchronously to ensure windows are removed immediately
      if (hwnd != 0) {
        win.DestroyWindow(hwnd);
      }
    }
    _hwnds.clear();
  }

  void _registerWindowClass() {
    final hInstance = win.GetModuleHandle(nullptr);
    final wc = calloc<win.WNDCLASSEX>();

    wc.ref.cbSize = sizeOf<win.WNDCLASSEX>();
    wc.ref.style = win.CS_HREDRAW | win.CS_VREDRAW;
    wc.ref.lpfnWndProc = _wndProcPtr;
    wc.ref.cbClsExtra = 0;
    wc.ref.cbWndExtra = sizeOf<IntPtr>(); // store index in GWLP_USERDATA
    wc.ref.hInstance = hInstance;
    wc.ref.hIcon = win.LoadIcon(hInstance, win.IDI_APPLICATION);
    wc.ref.hCursor = win.LoadCursor(0, win.IDC_ARROW);
    wc.ref.hbrBackground = win.GetStockObject(win.BLACK_BRUSH);
    wc.ref.lpszMenuName = nullptr;
    final className = win.TEXT(_className);
    wc.ref.lpszClassName = className;
    wc.ref.hIconSm = win.LoadIcon(hInstance, win.IDI_APPLICATION);

    final atom = win.RegisterClassEx(wc);
    // Free allocated strings/struct
    calloc.free(className);
    calloc.free(wc);

    if (atom == 0) {
      // If class already exists, it's fine.
    }
  }

  void _createOverlayForMonitor(MonitorInfo m) {
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
      return;
    }

    // Store monitor index in window user data
    win.SetWindowLongPtr(hwnd, win.GWLP_USERDATA, m.index);

    // Semi-transparent whole window
    const opacity = 180; // 0-255
    win.SetLayeredWindowAttributes(hwnd, 0, opacity, win.LWA_ALPHA);

    // Make it click-through and non-activating
    final exStyle = win.GetWindowLongPtr(hwnd, win.GWL_EXSTYLE);
    win.SetWindowLongPtr(
      hwnd,
      win.GWL_EXSTYLE,
      exStyle |
          win.WS_EX_NOACTIVATE |
          win.WS_EX_TRANSPARENT |
          win.WS_EX_TOPMOST |
          win.WS_EX_LAYERED |
          win.WS_EX_TOOLWINDOW,
    );
    // Show without activating
    win.ShowWindow(hwnd, win.SW_SHOWNOACTIVATE);
    win.UpdateWindow(hwnd);

    calloc.free(className);
    calloc.free(windowName);
    _hwnds.add(hwnd);
  }

  // Window procedure: paint a big centered number
  static int _wndProc(int hwnd, int uMsg, int wParam, int lParam) {
    switch (uMsg) {
      case win.WM_PAINT:
        _paint(hwnd);
        return 0;
      case win.WM_KEYDOWN:
      case win.WM_LBUTTONDOWN:
      case win.WM_RBUTTONDOWN:
      case win.WM_MBUTTONDOWN:
        // Close on any input
        win.PostMessage(hwnd, win.WM_CLOSE, 0, 0);
        return 0;
      case win.WM_CLOSE:
        win.DestroyWindow(hwnd);
        return 0;
      case win.WM_DESTROY:
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

      // Fill background (semi-transparent due to layered window alpha)
      final brush = win.CreateSolidBrush(0x000000); // black
      win.FillRect(hdc, rect, brush);
      win.DeleteObject(brush);

      // Prepare text
      final index = win.GetWindowLongPtr(hwnd, win.GWLP_USERDATA);
      final text = win.TEXT('${index + 1}');

      // Font size relative to window height
      final height = rect.ref.bottom - rect.ref.top;
      final fontSize = (height * 0.25).clamp(24, 4000).toInt();
      // Try to create a bold font of the desired height
      final lf = calloc<win.LOGFONT>();
      lf.ref.lfHeight = -fontSize; // negative -> character height
      lf.ref.lfWeight = 700; // FW_BOLD
      final hFont = win.CreateFontIndirect(lf);
      final oldFont = win.SelectObject(hdc, hFont);

      win.SetBkMode(hdc, win.TRANSPARENT);
      win.SetTextColor(hdc, 0x00FFFFFF); // white

      final dtRect = calloc<win.RECT>();
      dtRect.ref.left = rect.ref.left;
      dtRect.ref.top = rect.ref.top;
      dtRect.ref.right = rect.ref.right;
      dtRect.ref.bottom = rect.ref.bottom;

      win.DrawText(
        hdc,
        text,
        -1,
        dtRect,
        win.DT_CENTER | win.DT_VCENTER | win.DT_SINGLELINE,
      );

      // Cleanup
      win.SelectObject(hdc, oldFont);
      win.DeleteObject(hFont);
      calloc.free(lf);
      calloc.free(text);
      calloc.free(rect);
      calloc.free(dtRect);
    } finally {
      win.EndPaint(hwnd, ps);
      calloc.free(ps);
    }
  }
}
