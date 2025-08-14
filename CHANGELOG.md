# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

 
### Planned

- Linux platform support
- macOS platform support
- Multi‑monitor enumeration improvements on Windows
- Example application enhancements

## [0.1.1] - 2025-08-14

### Changed

- Clarified Windows-only support at the package level; kept Linux/macOS as planned
- Cleaned up comments and logs; unified tests to be platform-agnostic
- CI: added permissions/concurrency and example analyze; release test uses flutter test

### Fixed

- Resolved test failures on Linux/macOS runners by injecting a fake platform in unit tests

## [0.1.0] - 2025-08-14

 
### Added

- Initial release
- Core API design for monitor identification overlays
- Platform abstraction for cross‑platform support
- Windows implementation (topmost, click‑through, non‑activating, auto‑hide)
- Safe no‑op behavior on unsupported platforms
- Unit tests and documentation
- CI workflow (format, analyze, flutter test)
- Tag‑based release workflow (verify tag vs. pubspec version, publish to pub.dev, create GitHub Release)

 
### Technical Details

- Flutter SDK requirement: >=3.16.0
- Dart SDK requirement: >=3.8.1
- Platforms: Windows implemented; Linux and macOS planned
