import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:studyflow/core/theme/app_theme.dart';

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
    this.blur = 15.0,
    this.color,
    this.opacity = 0.2,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).extension<AppThemeExtension>()!.cardBackground;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeColor.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ?? Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
