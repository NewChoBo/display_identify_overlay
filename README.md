<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# display_identify_overlay

Project goal

This project aims to provide a lightweight Flutter package that displays temporary, on‑screen identifiers on each connected display (similar to the "Identify displays" feature in OS display settings) for desktop environments.

Why
- Quickly help users and developers identify which physical monitor corresponds to which logical display.
- Useful in multi‑monitor setups during onboarding, configuration, demos, or troubleshooting.

Scope
- Show large, clearly visible numbered labels on all connected displays.
- Basic customization for appearance (color, opacity, font size) and display duration.
- Desktop focus with Windows first; macOS and Linux to follow.

Non‑goals
- Managing display settings (resolution, scaling, arrangement) is out of scope.
- Persistent overlays or window management features are not included.

Status
- Early work in progress; API and implementation details will be defined next.
