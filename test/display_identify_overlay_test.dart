import 'package:flutter_test/flutter_test.dart';
import 'package:display_identify_overlay/display_identify_overlay.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DisplayIdentifyOverlay Tests', () {
    const MethodChannel channel = MethodChannel('display_identify_overlay');

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getPlatformVersion':
            return 'Test Platform Version';
          case 'getDisplayCount':
            return 2;
          default:
            return null;
        }
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('getPlatformVersion', () async {
      expect(await DisplayIdentifyOverlay.platformVersion, 'Test Platform Version');
    });

    test('getDisplayCount', () async {
      expect(await DisplayIdentifyOverlay.getDisplayCount(), 2);
    });
  });
}
