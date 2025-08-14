import 'dart:async';
import 'dart:ffi';

import 'package:display_identify_overlay/src/models/monitor_info.dart';
import 'package:display_identify_overlay/src/models/overlay_options.dart';
import 'package:display_identify_overlay/src/services/overlay_manager.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart' as win;

/// Windows implementation of [OverlayManager].
class OverlayManagerWindows implements OverlayManager {
  OverlayManagerWindows();
  _WindowsOverlay? _overlay;
  Timer? _autoHideTimer;

  // Separate sync callback so Timer can use a tearoff and avoid lint.
  void _onAutoHide() {
    unawaited(hideAllOverlays());
  }

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
  _WindowsOverlay(this.monitors, this.options);

  final List<MonitorInfo> monitors;
  final OverlayOptions options;

  final List<int> _hwnds = <int>[];

  // Map hwnd -> instance, so the static wndproc can access options/state.
  static final Map<int, _WindowsOverlay> _instances = <int, _WindowsOverlay>{};

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
        _instances.remove(hwnd);
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
    // We don't use extra bytes; monitor index is stored via GWLP_USERDATA.
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

    // Semi-transparent whole window: use style background alpha if provided.
  final bgAlpha = ((options.style.backgroundColor.a * 255.0).round()) & 0xFF; // 0-255
  win.SetLayeredWindowAttributes(hwnd, 0, bgAlpha, win.LWA_ALPHA);

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
    _instances[hwnd] = this;
  }

  // Window procedure: paint a big centered number
  static int _wndProc(int hwnd, int uMsg, int wParam, int lParam) {
    switch (uMsg) {
      case win.WM_PAINT:
        _paint(hwnd);
        return 0;
      case win.WM_DESTROY:
        // Cleanup mapping on destroy.
        _instances.remove(hwnd);
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
      final inst = _instances[hwnd];
      // Default to black if somehow not found.
  final bg = inst?.options.style.backgroundColor;
      // Convert ARGB -> COLORREF (0x00BBGGRR)
  final colorRef = (bg == null)
      ? 0x000000
      : (((bg.b * 255.0).round() & 0xFF) << 16) |
        (((bg.g * 255.0).round() & 0xFF) << 8) |
        ((bg.r * 255.0).round() & 0xFF);
      final brush = win.CreateSolidBrush(colorRef);
      win.FillRect(hdc, rect, brush);
      win.DeleteObject(brush);

      // Prepare text
      final index = win.GetWindowLongPtr(hwnd, win.GWLP_USERDATA);
      final text = win.TEXT('${index + 1}');

      // Font size relative to window height
      final height = rect.ref.bottom - rect.ref.top;
      // If a custom font size is set (> 0), honor it; otherwise scale to monitor.
      final style = inst?.options.style;
      final desired = (style != null && style.fontSize > 0)
          ? style.fontSize
          : height * 0.25;
      final fontSize = desired.clamp(24, 4000).toInt();
      // Try to create a font of the desired height/weight/family
      final lf = calloc<win.LOGFONT>();
      lf.ref.lfHeight = -fontSize; // negative -> character height
      // Map Flutter FontWeight (w100..w900) to GDI weight (100..900)
      final weight = () {
        if (style == null) return 700; // default bold
        // FontWeight exposes index 0..8 (w100..w900). Multiply by 100.
        try {
          final dynamic fw = style.fontWeight;
          final idx = fw.index as int?; // ignore if not available
          if (idx != null) return ((idx + 1) * 100).clamp(100, 900);
        } catch (_) {}
        return 700;
      }();
      lf.ref.lfWeight = weight;
      // Note: Setting lfFaceName via FFI is fragile across bindings.
      // We currently rely on the default font; consider adding safe face name support later.
      final hFont = win.CreateFontIndirect(lf);
      final oldFont = win.SelectObject(hdc, hFont);

      win.SetBkMode(hdc, win.TRANSPARENT);
      // Text color (COLORREF)
  final fg = style?.color;
  final textColor = (fg == null)
      ? 0x00FFFFFF
      : (((fg.b * 255.0).round() & 0xFF) << 16) |
        (((fg.g * 255.0).round() & 0xFF) << 8) |
        ((fg.r * 255.0).round() & 0xFF);
      final shadowColor = style?.shadowColor;
  final shadowColorRef = (shadowColor == null)
      ? null
      : (((shadowColor.b * 255.0).round() & 0xFF) << 16) |
        (((shadowColor.g * 255.0).round() & 0xFF) << 8) |
        ((shadowColor.r * 255.0).round() & 0xFF);
      final padding = style?.padding;
      final padLeft = padding?.left.toInt() ?? 0;
      final padTop = padding?.top.toInt() ?? 0;
      final padRight = padding?.right.toInt() ?? 0;
      final padBottom = padding?.bottom.toInt() ?? 0;

      final dtRect = calloc<win.RECT>();
      // Start with full rect, then apply padding and alignment.
      dtRect.ref.left = rect.ref.left + padLeft;
      dtRect.ref.top = rect.ref.top + padTop;
      dtRect.ref.right = rect.ref.right - padRight;
      dtRect.ref.bottom = rect.ref.bottom - padBottom;

      // Alignment flags
      int flags = win.DT_SINGLELINE;
      final pos = inst?.options.position;
      switch (pos) {
        case OverlayPosition.topLeft:
          flags |= win.DT_LEFT | win.DT_TOP;
          break;
        case OverlayPosition.topRight:
          flags |= win.DT_RIGHT | win.DT_TOP;
          break;
        case OverlayPosition.bottomLeft:
          flags |= win.DT_LEFT | win.DT_BOTTOM;
          break;
        case OverlayPosition.bottomRight:
          flags |= win.DT_RIGHT | win.DT_BOTTOM;
          break;
        case OverlayPosition.topCenter:
          flags |= win.DT_CENTER | win.DT_TOP;
          break;
        case OverlayPosition.bottomCenter:
          flags |= win.DT_CENTER | win.DT_BOTTOM;
          break;
        case OverlayPosition.leftCenter:
          flags |= win.DT_LEFT | win.DT_VCENTER;
          break;
        case OverlayPosition.rightCenter:
          flags |= win.DT_RIGHT | win.DT_VCENTER;
          break;
        case OverlayPosition.center:
        default:
          flags |= win.DT_CENTER | win.DT_VCENTER;
          break;
      }

      // Optional shadow: draw offset text first
      if (shadowColorRef != null && style != null) {
        final shadowOffset = style.shadowOffset;
        final shadowRect = calloc<win.RECT>();
        shadowRect.ref.left = dtRect.ref.left + shadowOffset.dx.toInt();
        shadowRect.ref.top = dtRect.ref.top + shadowOffset.dy.toInt();
        shadowRect.ref.right = dtRect.ref.right + shadowOffset.dx.toInt();
        shadowRect.ref.bottom = dtRect.ref.bottom + shadowOffset.dy.toInt();
        win.SetTextColor(hdc, shadowColorRef);
        win.DrawText(hdc, text, -1, shadowRect, flags);
        calloc.free(shadowRect);
      }

      // Draw main text
      win.SetTextColor(hdc, textColor);
      win.DrawText(hdc, text, -1, dtRect, flags);

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
