import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Gentle scale-pulse around an icon — used instead of emoji.
class PulseIcon extends StatefulWidget {
  const PulseIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 18,
    this.boxSize,
    this.background,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double? boxSize;
  final Color? background;

  @override
  State<PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<PulseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = ScaleTransition(
      scale: Tween(begin: 0.88, end: 1.12)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut)),
      child: Icon(widget.icon, size: widget.size, color: widget.color),
    );
    if (widget.boxSize == null) return icon;
    return Container(
      width: widget.boxSize,
      height: widget.boxSize,
      decoration: BoxDecoration(
        color: widget.background ?? widget.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(widget.boxSize! * 0.3),
      ),
      child: Center(child: icon),
    );
  }
}

/// Flickering diya flame — organic scale/sway/glow jitter.
class FlameIcon extends StatefulWidget {
  const FlameIcon({super.key, this.size = 26, this.color = const Color(0xFFFFD37E)});

  final double size;
  final Color color;

  @override
  State<FlameIcon> createState() => _FlameIconState();
}

class _FlameIconState extends State<FlameIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400))
    ..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value * 2 * math.pi;
        final flicker = 1 +
            0.06 * math.sin(t * 3) +
            0.04 * math.sin(t * 7 + 1.3) +
            0.03 * math.sin(t * 13 + 0.4);
        final sway = 0.04 * math.sin(t * 5 + 0.8);
        return Transform.rotate(
          angle: sway,
          child: Transform.scale(
            scale: flicker,
            alignment: Alignment.bottomCenter,
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [widget.color, Colors.white.withOpacity(0.95)],
              ).createShader(rect),
              child: Icon(Icons.local_fire_department_rounded,
                  size: widget.size, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
