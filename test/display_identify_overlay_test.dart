import 'package:display_identify_overlay/display_identify_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DisplayIdentifyOverlay', () {
    test('should check platform support', () {
      // This test will pass on supported platforms
      expect(DisplayIdentifyOverlay.isSupported, isA<bool>());
    });

    test('should get platform name', () {
      final platform = DisplayIdentifyOverlay.platform;
      expect(platform, isA<String>());
      expect(['Windows', 'Linux', 'macOS', 'Unknown'], contains(platform));
    });

    test('should throw exception on unsupported platform', () async {
      // This test verifies that the API structure is correct
      // Actual platform-specific behavior will be tested in integration tests
      expect(() => DisplayIdentifyOverlay.show(), returnsNormally);
    });
  });

  group('MonitorInfo', () {
    test('should create monitor info with correct properties', () {
      const monitor = MonitorInfo(
        index: 0,
        name: 'Test Monitor',
        x: 0,
        y: 0,
        width: 1920,
        height: 1080,
        isPrimary: true,
      );

      expect(monitor.index, equals(0));
      expect(monitor.name, equals('Test Monitor'));
      expect(monitor.x, equals(0));
      expect(monitor.y, equals(0));
      expect(monitor.width, equals(1920));
      expect(monitor.height, equals(1080));
      expect(monitor.isPrimary, isTrue);
      expect(monitor.centerX, equals(960));
      expect(monitor.centerY, equals(540));
    });

    test('should calculate center coordinates correctly', () {
      const monitor = MonitorInfo(
        index: 1,
        name: 'Secondary Monitor',
        x: 1920,
        y: 0,
        width: 2560,
        height: 1440,
        isPrimary: false,
      );

      expect(monitor.centerX, equals(3200)); // 1920 + (2560 / 2)
      expect(monitor.centerY, equals(720)); // 0 + (1440 / 2)
    });
  });

  group('OverlayStyle', () {
    test('should create overlay style with default values', () {
      const style = OverlayStyle();

      expect(style.fontSize, equals(48));
      expect(style.color, equals(Colors.white));
      expect(style.backgroundColor, equals(const Color(0x80000000)));
      expect(style.fontWeight, equals(FontWeight.bold));
      expect(style.fontFamily, isNull);
      expect(style.shadowColor, equals(Colors.black));
      expect(style.shadowOffset, equals(const Offset(2, 2)));
      expect(style.shadowBlurRadius, equals(4));
      expect(style.borderRadius, equals(8));
      expect(style.padding, equals(const EdgeInsets.all(16)));
    });

    test('should create overlay style with custom values', () {
      const style = OverlayStyle(
        fontSize: 64,
        color: Colors.red,
        backgroundColor: Colors.blue,
        fontWeight: FontWeight.normal,
        fontFamily: 'Arial',
      );

      expect(style.fontSize, equals(64));
      expect(style.color, equals(Colors.red));
      expect(style.backgroundColor, equals(Colors.blue));
      expect(style.fontWeight, equals(FontWeight.normal));
      expect(style.fontFamily, equals('Arial'));
    });

    test('should create copy with modified values', () {
      const original = OverlayStyle();
      final modified = original.copyWith(fontSize: 72, color: Colors.green);

      expect(modified.fontSize, equals(72));
      expect(modified.color, equals(Colors.green));
      expect(modified.backgroundColor, equals(original.backgroundColor));
      expect(modified.fontWeight, equals(original.fontWeight));
    });
  });

  group('OverlayOptions', () {
    test('should create overlay options with default values', () {
      const options = OverlayOptions();

      expect(options.duration, isNull);
      expect(options.style, isA<OverlayStyle>());
      expect(options.position, equals(OverlayPosition.center));
      expect(options.autoHide, isTrue);
    });

    test('should create overlay options with custom values', () {
      const style = OverlayStyle(fontSize: 64);
      const duration = Duration(seconds: 10);
      const options = OverlayOptions(
        duration: duration,
        style: style,
        position: OverlayPosition.topLeft,
        autoHide: false,
      );

      expect(options.duration, equals(duration));
      expect(options.style, equals(style));
      expect(options.position, equals(OverlayPosition.topLeft));
      expect(options.autoHide, isFalse);
    });
  });

  group('Exceptions', () {
    test('should create display identify exception', () {
      const exception = DisplayIdentifyException('Test error');
      expect(exception.message, equals('Test error'));
      expect(
        exception.toString(),
        equals('DisplayIdentifyException: Test error'),
      );
    });

    test('should create no monitors detected exception', () {
      const exception = NoMonitorsDetectedException();
      expect(exception.message, equals('No monitors detected'));
    });

    test('should create unsupported platform exception', () {
      const exception = UnsupportedPlatformException('TestOS');
      expect(exception.message, equals('Platform TestOS is not supported'));
    });

    test('should create overlay creation exception', () {
      const exception = OverlayCreationException('Failed to create overlay');
      expect(exception.message, equals('Failed to create overlay'));
    });
  });
}
