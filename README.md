# display_identify_overlay

A Flutter package that displays monitor index numbers as overlays on all connected displays. Perfect for identifying monitors in multi‑display setups.

[![CI](https://github.com/NewChoBo/display_identify_overlay/actions/workflows/ci.yml/badge.svg)](https://github.com/NewChoBo/display_identify_overlay/actions/workflows/ci.yml)
[![pub.dev](https://img.shields.io/pub/v/display_identify_overlay.svg)](https://pub.dev/packages/display_identify_overlay)

## Project Goal

This project aims to provide a lightweight Flutter package that displays temporary, on‑screen identifiers on each connected display (similar to the "Identify displays" feature in OS display settings) for desktop environments.

## Why

- Quickly help users and developers identify which physical monitor corresponds to which logical display.
- Useful in multi‑monitor setups during onboarding, configuration, demos, or troubleshooting.

## Scope

- Show large, clearly visible numbered labels on all connected displays.
- Basic customization for appearance (color, opacity, font size) and display duration.
- Desktop focus with Windows first; macOS and Linux to follow.

## Non‑goals

- Managing display settings (resolution, scaling, arrangement) is out of scope.
- Persistent overlays or window management features are not included.

## Status

- Windows overlay implemented (click‑through, non‑activating, auto‑hide). Linux/macOS planned. APIs are stable and safe no‑op on unsupported platforms.

## Features

- [x] Basic project structure and API design
- [x] Platform detection and abstraction
- [x] Monitor information model
- [x] Overlay styling and positioning options
- [x] Exception handling
- [x] Windows implementation (Win32 overlay)
- [ ] Linux implementation (planned)
- [ ] macOS implementation (planned)
- [x] Tests (unit)
- [x] Documentation
- [x] CI (analyze + tests)
- [x] Tag‑based release automation

## Getting Started

### Prerequisites

- Flutter SDK (>=3.16.0)
- Dart SDK (>=3.8.1)

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  display_identify_overlay: ^0.1.0
```

### Usage

```dart
import 'package:display_identify_overlay/display_identify_overlay.dart';
import 'package:flutter/material.dart';

// Basic usage (no-op on unsupported platforms like macOS/Linux for now)
await DisplayIdentifyOverlay.show();

// With custom options
await DisplayIdentifyOverlay.show(
  OverlayOptions(
    duration: Duration(seconds: 5),
    style: OverlayStyle(
      fontSize: 48,
      color: Colors.red,
      backgroundColor: Colors.black.withOpacity(0.5),
    ),
    position: OverlayPosition.center,
  ),
);

// Hide overlays manually
await DisplayIdentifyOverlay.hide();

// Get monitor information (returns [] on unsupported platforms)
final monitors = await DisplayIdentifyOverlay.getMonitors();
```

## API Reference

### DisplayIdentifyOverlay

The main class providing static methods for overlay management.

#### Methods

- `show([OverlayOptions? options])` - Shows monitor identification overlays
- `hide()` - Hides all currently displayed overlays
- `getMonitors()` - Gets information about all connected monitors

#### Properties

- `isSupported` - Checks if the current platform is supported
- `platform` - Gets the current platform name

### OverlayOptions

Configuration options for the overlay display.

- `duration` - How long to display the overlay
- `style` - The style configuration for the overlay
- `position` - The position of the overlay on each monitor
- `autoHide` - Whether to automatically hide the overlay after the duration

### OverlayStyle

Style configuration for the overlay display.

- `fontSize` - The font size for the monitor number
- `color` - The text color
- `backgroundColor` - The background color of the overlay
- `fontWeight` - The font weight
- `fontFamily` - The font family
- `shadowColor` - The shadow color
- `shadowOffset` - The shadow offset
- `shadowBlurRadius` - The shadow blur radius
- `borderRadius` - The border radius of the overlay
- `padding` - The padding around the text

### MonitorInfo

Information about a monitor.

- `index` - The monitor index (0-based)
- `name` - The monitor name/identifier
- `x`, `y` - The monitor's top-left corner coordinates
- `width`, `height` - The monitor's dimensions
- `isPrimary` - Whether this monitor is the primary display
- `centerX`, `centerY` - The monitor's center coordinates

## Platform Support

- Windows: Implemented
- Linux: Planned (current behavior is safe no‑op)
- macOS: Planned (current behavior is safe no‑op)

## Release & Publishing

Publishing to pub.dev is automated on version tags that match `pubspec.yaml`.

1. Configure pub.dev credentials once (GitHub secret):

- On your machine, run `dart pub login` and complete OAuth.
- Copy the contents of your pub credentials JSON (on Windows: `%APPDATA%\dart\pub-credentials.json`).
- In GitHub → Settings → Secrets and variables → Actions, add a new secret:
  - Name: `PUB_CREDENTIALS_JSON`
  - Value: paste the JSON content

1. Cut a release:

- Bump `version:` in `pubspec.yaml` (e.g., `0.1.1`) and commit.
- Create and push a matching tag with a `v` prefix:

```powershell
git add pubspec.yaml; git commit -m "chore: release 0.1.1"
git tag -a v0.1.1 -m "Release 0.1.1"
git push origin v0.1.1
```

The workflow will:

- Run format/analyze/tests
- Verify the tag matches `pubspec.yaml` version
- Publish to pub.dev (if `PUB_CREDENTIALS_JSON` is set)
- Create a GitHub Release with notes

Manual publish (fallback):

1. Ensure `pubspec.yaml` has name, description, version, homepage/repository, and a valid `LICENSE` file at the repo root.

2. Validate locally:

- `dart format .`
- `flutter analyze`
- `dart pub publish --dry-run`

1. Publish: `dart pub publish`

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the "Identify displays" feature in operating system display settings
- Built with Flutter for cross-platform desktop support
