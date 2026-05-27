import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A reusable base widget for creating shimmer loading skeleton screens.
/// It uses the `shimmer` package to render standard fading transition effects.
class Skeleton extends StatelessWidget {
  /// The width of the skeleton box.
  final double? width;
  /// The height of the skeleton box.
  final double? height;
  /// The border radius of the skeleton box (defaults to 8.0).
  final BorderRadiusGeometry? borderRadius;

  /// Creates a [Skeleton] widget.
  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
      highlightColor: isDark ? const Color(0xFF353535) : const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}
