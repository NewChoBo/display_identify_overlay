import 'package:flutter/material.dart';

/// Style configuration for the overlay display.
class OverlayStyle {
  /// Creates an [OverlayStyle] with the given parameters.
  const OverlayStyle({
    this.fontSize = 48,
    this.color = Colors.white,
    this.backgroundColor = const Color(0x80000000),
    this.fontWeight = FontWeight.bold,
    this.fontFamily,
    this.shadowColor = Colors.black,
    this.shadowOffset = const Offset(2, 2),
    this.shadowBlurRadius = 4,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.all(16),
  });

  /// The font size for the monitor number.
  final double fontSize;

  /// The text color.
  final Color color;

  /// The background color of the overlay.
  final Color backgroundColor;

  /// The font weight.
  final FontWeight fontWeight;

  /// The font family.
  final String? fontFamily;

  /// The shadow color.
  final Color shadowColor;

  /// The shadow offset.
  final Offset shadowOffset;

  /// The shadow blur radius.
  final double shadowBlurRadius;

  /// The border radius of the overlay.
  final double borderRadius;

  /// The padding around the text.
  final EdgeInsets padding;

  /// Creates a copy of this [OverlayStyle] with the given fields replaced.
  OverlayStyle copyWith({
    double? fontSize,
    Color? color,
    Color? backgroundColor,
    FontWeight? fontWeight,
    String? fontFamily,
    Color? shadowColor,
    Offset? shadowOffset,
    double? shadowBlurRadius,
    double? borderRadius,
    EdgeInsets? padding,
  }) => OverlayStyle(
    fontSize: fontSize ?? this.fontSize,
    color: color ?? this.color,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    fontWeight: fontWeight ?? this.fontWeight,
    fontFamily: fontFamily ?? this.fontFamily,
    shadowColor: shadowColor ?? this.shadowColor,
    shadowOffset: shadowOffset ?? this.shadowOffset,
    shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
    borderRadius: borderRadius ?? this.borderRadius,
    padding: padding ?? this.padding,
  );

  @override
  String toString() =>
      'OverlayStyle(fontSize: $fontSize, color: $color, '
      'backgroundColor: $backgroundColor, fontWeight: $fontWeight)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverlayStyle &&
          other.fontSize == fontSize &&
          other.color == color &&
          other.backgroundColor == backgroundColor &&
          other.fontWeight == fontWeight &&
          other.fontFamily == fontFamily &&
          other.shadowColor == shadowColor &&
          other.shadowOffset == shadowOffset &&
          other.shadowBlurRadius == shadowBlurRadius &&
          other.borderRadius == borderRadius &&
          other.padding == padding;

  @override
  int get hashCode => Object.hash(
    fontSize,
    color,
    backgroundColor,
    fontWeight,
    fontFamily,
    shadowColor,
    shadowOffset,
    shadowBlurRadius,
    borderRadius,
    padding,
  );
}
