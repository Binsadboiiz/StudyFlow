import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final Color? color;
  final double opacity;
  final BoxBorder? border;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.padding,
    this.blur = 25.0, // Increased default blur for liquid glass trend
    this.color,
    this.opacity = 0.08, // Light opacity default to let liquid shine through
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Choose appropriate base tint color if not explicitly defined
    final baseColor = color ?? (isDark ? Colors.white : Colors.black);
    final fillColor = baseColor.withValues(alpha: opacity);

    // Premium specular light highlight gradient for card borders
    final borderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              Colors.white.withValues(alpha: 0.18),
              Colors.white.withValues(alpha: 0.03),
              Colors.black.withValues(alpha: 0.10),
              Colors.white.withValues(alpha: 0.08),
            ]
          : [
              Colors.white.withValues(alpha: 0.45),
              Colors.white.withValues(alpha: 0.10),
              Colors.black.withValues(alpha: 0.02),
              Colors.white.withValues(alpha: 0.20),
            ],
      stops: const [0.0, 0.45, 0.55, 1.0],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: CustomPaint(
          foregroundPainter: border == null
              ? GlassBorderPainter(
                  radius: borderRadius,
                  strokeWidth: 1.2,
                  gradient: borderGradient,
                )
              : null,
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: border, // Use provided border only if overriding
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassBorderPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  GlassBorderPainter({
    required this.radius,
    required this.strokeWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant GlassBorderPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gradient != gradient;
  }
}
