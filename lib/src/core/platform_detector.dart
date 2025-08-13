import 'dart:io';

/// Centralized platform detection utility.
class PlatformDetector {
  PlatformDetector._();

  /// Checks if the current platform is supported.
  static bool get isSupported => Platform.isWindows; // Extend when ready

  /// Gets the current platform name.
  static String get platform => Platform.isWindows
      ? 'Windows'
      : Platform.isLinux
      ? 'Linux'
      : Platform.isMacOS
      ? 'macOS'
      : 'Unknown';

  /// Checks if the current platform is Windows.
  static bool get isWindows => Platform.isWindows;

  /// Checks if the current platform is Linux.
  static bool get isLinux => Platform.isLinux;

  /// Checks if the current platform is macOS.
  static bool get isMacOS => Platform.isMacOS;
}
