import 'package:flutter/material.dart';

/// Gives a subtle "breathing" scale effect to the child.
/// Recommended for Cards and Mascot.
class BreathingWidget extends StatefulWidget {
  final Widget child;
  final double scaleTarget;
  final Duration duration;

  const BreathingWidget({
    super.key,
    required this.child,
    this.scaleTarget = 1.01,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<BreathingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: widget.scaleTarget).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: widget.child);
  }
}

/// Gives a subtle glowing pulse effect to the child.
/// Recommended for CTA Buttons to make them feel active.
class GlowPulseWidget extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final BorderRadius? borderRadius;
  final Duration duration;

  const GlowPulseWidget({
    super.key,
    required this.child,
    required this.glowColor,
    this.borderRadius,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<GlowPulseWidget> createState() => _GlowPulseWidgetState();
}

class _GlowPulseWidgetState extends State<GlowPulseWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.3 * _animation.value),
                blurRadius: 15 + (10 * _animation.value),
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
