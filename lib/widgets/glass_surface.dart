import 'dart:ui';
import 'package:flutter/material.dart';

/// Dark rounded surface with optional frosted-glass blur
// This frosted glass is expensive but it looks fucking awsome
//
// The blur filter is only used when [blur] is on AND [opacity] is
// strictly between 0 and 1 (at 0 it's transparent, at 1 it's solid,
// so the expensive filter would do nothing when its 0 or 1)
// 
class GlassSurface extends StatelessWidget {
  final Widget child;
  final double opacity; // 0..1
  final bool blur;
  final double radius;
  final EdgeInsetsGeometry padding;

  const GlassSurface({
    super.key,
    required this.child,
    required this.opacity,
    required this.blur,
    this.radius = 999,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    final useBlur = blur && opacity > 0 && opacity < 1;
    final r = BorderRadius.circular(radius);

    final surface = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF161616).withValues(alpha: opacity),
        borderRadius: r,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14 * opacity),
        ),
      ),
      child: child,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45 * opacity),

            // the actual which apply blur
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: useBlur
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: surface,
              )
            : surface,
      ),
    );
  }
}
