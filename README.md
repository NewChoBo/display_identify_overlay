# Display Identify Overlay

A Flutter library that displays monitor index overlays on each connected display to help identify which monitor is which.

## Purpose

This library provides a simple way to show overlay UI elements on each monitor displaying the corresponding monitor index. This is particularly useful for:

- Multi-monitor setups where you need to identify which display is which
- Development and testing scenarios involving multiple screens
- Display configuration and management applications
- Screen recording or streaming setups with multiple monitors

## Features

- Automatically detects all connected monitors
- Displays overlay UI with monitor index on each display
- Lightweight and easy to integrate
- Native Windows implementation for optimal performance
- Customizable overlay appearance

## Platform Support

- ✅ **Windows** - Fully supported
- ⏳ **macOS** - Planned for future release
- ⏳ **Linux** - Planned for future release

> **Note:** Currently, this library only supports Windows. macOS and Linux support will be added in future versions.

## Requirements

- Flutter SDK 3.19.0 or higher
- Dart SDK 3.8.0 or higher  
- Windows 10 or later
- Multi-monitor setup (for testing overlay functionality)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  display_identify_overlay: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Usage

```dart
import 'package:display_identify_overlay/display_identify_overlay.dart';

// Get the number of connected displays
int displayCount = await DisplayIdentifyOverlay.getDisplayCount();
print('Connected displays: $displayCount');

// Get platform version (for debugging)
String? version = await DisplayIdentifyOverlay.platformVersion;
print('Platform: $version');
```

## Development Status

⚠️ **This package is currently under development.** 
- Basic structure and API are implemented
- Native platform implementations are in progress
- Display overlay functionality will be added soon

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.