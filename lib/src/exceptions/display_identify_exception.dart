/// Custom exception for display identify overlay operations.
class DisplayIdentifyException implements Exception {
  /// Creates a [DisplayIdentifyException] with the given [message].
  const DisplayIdentifyException(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'DisplayIdentifyException: $message';
}

/// Exception thrown when no monitors are detected.
class NoMonitorsDetectedException extends DisplayIdentifyException {
  /// Creates a [NoMonitorsDetectedException].
  const NoMonitorsDetectedException() : super('No monitors detected');
}

/// Exception thrown when platform is not supported.
class UnsupportedPlatformException extends DisplayIdentifyException {
  /// Creates an [UnsupportedPlatformException] for the given [platform].
  const UnsupportedPlatformException(String platform)
    : super('Platform $platform is not supported');
}

/// Exception thrown when overlay creation fails.
class OverlayCreationException extends DisplayIdentifyException {
  /// Creates an [OverlayCreationException] with the given [message].
  const OverlayCreationException(super.message);
}
