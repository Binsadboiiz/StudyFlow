import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..addListener(() {
        setState(() {
          _updateParticles();
        });
      })
      ..repeat();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_particles.isEmpty) {
      final size = MediaQuery.of(context).size;
      _generateParticles(size);
    }
  }

  void _generateParticles(Size size) {
    for (int i = 0; i < 40; i++) {
      _particles.add(Particle(
        x: _random.nextDouble() * size.width,
        y: _random.nextDouble() * size.height,
        speedX: (_random.nextDouble() - 0.5) * 0.5,
        speedY: (_random.nextDouble() - 0.5) * 0.5,
        radius: _random.nextDouble() * 3 + 1,
        alpha: _random.nextDouble() * 0.5 + 0.1,
      ));
    }
  }

  void _updateParticles() {
    final size = MediaQuery.of(context).size;
    for (var particle in _particles) {
      particle.x += particle.speedX;
      particle.y += particle.speedY;

      if (particle.x < 0 || particle.x > size.width) particle.speedX *= -1;
      if (particle.y < 0 || particle.y > size.height) particle.speedY *= -1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Background
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        // Particles
        CustomPaint(
          size: Size.infinite,
          painter: ParticlePainter(particles: _particles, color: Theme.of(context).colorScheme.primary),
        ),
        // Foreground Content
        widget.child,
      ],
    );
  }
}

class Particle {
  double x;
  double y;
  double speedX;
  double speedY;
  double radius;
  double alpha;

  Particle({
    required this.x,
    required this.y,
    required this.speedX,
    required this.speedY,
    required this.radius,
    required this.alpha,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;

  ParticlePainter({required this.particles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = color.withValues(alpha: particle.alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(particle.x, particle.y), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
