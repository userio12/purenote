import 'dart:ui';
import 'package:flutter/widgets.dart';

class GlassEffect {
  GlassEffect._();

  static BoxDecoration glass({
    double backgroundOpacity = 0.85,
    double blur = 20,
    Color borderColor = const Color(0x1AFFFFFF),
    double borderOpacity = 0.1,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      borderRadius: borderRadius,
      border: Border.all(color: borderColor.withValues(alpha: borderOpacity), width: 1),
      backgroundBlendMode: BlendMode.overlay,
    );
  }

  static ClipRRect clipBlur({
    required Widget child,
    double blur = 20,
    BorderRadius? borderRadius,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: child,
      ),
    );
  }
}
