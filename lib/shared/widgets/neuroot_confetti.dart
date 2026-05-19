import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double rotation;
  double rotationSpeed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class NeurootConfetti extends StatefulWidget {
  final bool isPlaying;
  const NeurootConfetti({super.key, this.isPlaying = true});

  @override
  State<NeurootConfetti> createState() => _NeurootConfettiState();
}

class _NeurootConfettiState extends State<NeurootConfetti> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    if (widget.isPlaying) {
      _spawnParticles();
      _controller.repeat();
    }
  }

  void _spawnParticles() {
    final colors = [
      const Color(0xFFC4BCAF), // Cozy sage
      const Color(0xFFFFF3C4), // Cozy yellow
      const Color(0xFFFFD4D4), // Soft red
      const Color(0xFFE2F0D9), // Light green
      const Color(0xFFEBF5EB), // Sage
      const Color(0xFFFFF9F1), // Cream
    ];

    for (int i = 0; i < 90; i++) {
      // Spawn in top-center with custom velocity shooting upward/outward
      final angle = -pi / 2 + (_random.nextDouble() - 0.5) * (pi / 1.5);
      final speed = 4.0 + _random.nextDouble() * 7.0;
      _particles.add(
        ConfettiParticle(
          x: 0.5, // Start in middle horizontally
          y: 0.25, // Start near top vertically
          vx: cos(angle) * speed * 0.008,
          vy: sin(angle) * speed * 0.008,
          size: 6.0 + _random.nextDouble() * 12.0,
          color: colors[_random.nextInt(colors.length)],
          rotation: _random.nextDouble() * pi * 2,
          rotationSpeed: -0.15 + _random.nextDouble() * 0.3,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(NeurootConfetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _particles.clear();
      _spawnParticles();
      _controller.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Update particles
        for (final p in _particles) {
          p.x += p.vx;
          p.y += p.vy;
          p.vy += 0.00035; // Gravity
          p.vx *= 0.985; // Friction
          p.rotation += p.rotationSpeed;
        }

        return CustomPaint(
          painter: _ConfettiPainter(_particles),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      if (p.x < -0.2 || p.x > 1.2 || p.y > 1.2) continue;

      final px = p.x * size.width;
      final py = p.y * size.height;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);

      paint.color = p.color;
      // Draw a neat rectangular confetti piece
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
