import 'dart:async';
import 'package:flutter/services.dart';

/// Main class for managing display identification overlays
class DisplayIdentifyOverlay {
  static const MethodChannel _channel = MethodChannel(
    'display_identify_overlay',
  );

  /// Get the number of connected displays
  static Future<int> getDisplayCount() async {
    try {
      final int count = await _channel.invokeMethod('getDisplayCount');
      return count;
    } on PlatformException catch (e) {
      throw Exception('Failed to get display count: ${e.message}');
    }
  }

  /// Get platform version (for testing purposes)
  static Future<String?> get platformVersion async {
    try {
      final String? version = await _channel.invokeMethod('getPlatformVersion');
      return version;
    } on PlatformException {
      return 'Failed to get platform version.';
    }
  }
}
