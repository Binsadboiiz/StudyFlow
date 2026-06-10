import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/providers/performance_provider.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 30 seconds for a very slow, calming, and organic fluid movement
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    // Note: We don't start the controller here because build will manage it based on performance provider
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final isLowPerf = context.watch<PerformanceProvider>().isLowPerformance;

    // Manage animation ticking state based on Performance Mode
    if (isLowPerf) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    } else {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }

    if (isLowPerf) {
      // Return a clean, premium static gradient background for low performance mode
      return Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        theme.scaffoldBackgroundColor,
                        const Color(0xFF1E272C), // Sleek charcoal tint
                      ]
                    : [
                        theme.scaffoldBackgroundColor,
                        const Color(0xFFF0F4F8), // Soft slate/ice tint
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          widget.child,
        ],
      );
    }

    // Translucent glowing colors optimized for overlaying glass cards
    final blobColors = isDark
        ? [
            const Color(0xFF10B981).withValues(alpha: 0.15), // Emerald glow
            const Color(0xFF6366F1).withValues(alpha: 0.13), // Deep Indigo
            const Color(0xFF06B6D4).withValues(alpha: 0.15), // Electric Cyan
            const Color(0xFFD946EF).withValues(alpha: 0.10), // Soft Orchid
          ]
        : [
            const Color(0xFF34D399).withValues(alpha: 0.20), // Mint Green
            const Color(0xFF818CF8).withValues(alpha: 0.16), // Lavender
            const Color(0xFF22D3EE).withValues(alpha: 0.20), // Sky Cyan
            const Color(0xFFF472B6).withValues(alpha: 0.14), // Rose Pink
          ];

    return Stack(
      children: [
        // Base solid color
        Container(
          width: double.infinity,
          height: double.infinity,
          color: theme.scaffoldBackgroundColor,
        ),
        // Animated liquid mesh blobs wrapped in RepaintBoundary to prevent constant app-wide repaints.
        // We use ImageFiltered to perform the blur on the GPU backing texture instead of calculating blurs
        // on individual vector paths using MaskFilter.blur inside the painter loop.
        RepaintBoundary(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: 90.0,
              sigmaY: 90.0,
              tileMode: TileMode.decal,
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: LiquidMeshPainter(
                    progress: _controller.value,
                    colors: blobColors,
                  ),
                );
              },
            ),
          ),
        ),
        // Content overlay
        widget.child,
      ],
    );
  }
}

class LiquidMeshPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  LiquidMeshPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final angle = progress * 2 * pi;
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Blob 1: Top-Left region, rotates clockwise
    final offset1 = Offset(
      size.width * (0.25 + 0.15 * sin(angle)),
      size.height * (0.25 + 0.10 * cos(angle)),
    );
    paint.color = colors[0];
    canvas.drawCircle(offset1, size.width * 0.35, paint);

    // Blob 2: Bottom-Right region, rotates counter-clockwise
    final offset2 = Offset(
      size.width * (0.75 + 0.12 * cos(angle + pi / 2)),
      size.height * (0.70 + 0.15 * sin(angle + pi / 2)),
    );
    paint.color = colors[1];
    canvas.drawCircle(offset2, size.width * 0.40, paint);

    // Blob 3: Center-Left region, moves in a slow figure-8
    final offset3 = Offset(
      size.width * (0.35 + 0.18 * sin(angle * 2)),
      size.height * (0.60 + 0.12 * cos(angle)),
    );
    paint.color = colors[2];
    canvas.drawCircle(offset3, size.width * 0.33, paint);

    // Blob 4: Center-Right region, moves diagonally
    final offset4 = Offset(
      size.width * (0.70 + 0.15 * sin(angle + pi)),
      size.height * (0.30 + 0.15 * cos(angle + pi)),
    );
    paint.color = colors[3];
    canvas.drawCircle(offset4, size.width * 0.30, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidMeshPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.colors != colors;
  }
}
