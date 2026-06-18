import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth_provider.dart';

/// Premium full-screen brand intro, rendered natively (no video) so it scales
/// crisply to any screen size or density and behaves identically on Android and
/// iOS. The circular AYA emblem is revealed over an animated background of a
/// deep gradient, golden light rays and drifting particles, with a short chime.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Brand palette derived from the logo.
  static const _gold = Color(0xFFE8A33D);
  static const _bgTop = Color(0xFF0B1224);
  static const _bgMid = Color(0xFF05070F);

  late final AnimationController _ambient =
      AnimationController(vsync: this, duration: const Duration(seconds: 9))
        ..repeat();
  late final AnimationController _reveal = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1700));

  final AudioPlayer _player = AudioPlayer();
  final List<_Particle> _particles = [];
  final Completer<void> _done = Completer<void>();
  Timer? _minTimer;

  @override
  void initState() {
    super.initState();
    final random = math.Random(7);
    for (var i = 0; i < 54; i++) {
      _particles.add(_Particle.random(random));
    }
    _reveal.forward();
    _playChime();
    // Minimum on-screen time for the reveal to land; tap skips early.
    _minTimer = Timer(const Duration(milliseconds: 3600), _finish);
    _routeWhenReady();
  }

  Future<void> _playChime() async {
    try {
      await _player.setVolume(0.9);
      await _player.play(AssetSource('audio/intro.mp3'));
    } catch (_) {
      // Audio unavailable — the visual intro still plays.
    }
  }

  void _finish() {
    if (!_done.isCompleted) _done.complete();
  }

  Future<void> _routeWhenReady() async {
    await Future.wait([
      ref.read(authProvider.notifier).bootstrap(),
      _done.future,
    ]);
    if (!mounted) return;
    final auth = ref.read(authProvider);
    final authed = auth.status == AuthStatus.authenticated;
    final isAdmin =
        auth.member?.role == 'president' || auth.member?.role == 'secretary';
    context.go(!authed ? '/login' : (isAdmin ? '/admin' : '/dashboard'));
  }

  @override
  void dispose() {
    _minTimer?.cancel();
    _ambient.dispose();
    _reveal.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bgMid,
        body: GestureDetector(
          onTap: _finish, // tap anywhere to skip
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              final logoSize = math.min(w * 0.52, 220.0);
              final center = Offset(w / 2, h * 0.42);

              return Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_bgTop, _bgMid, _bgTop],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  // Animated rays + glow + particles.
                  AnimatedBuilder(
                    animation: Listenable.merge([_ambient, _reveal]),
                    builder: (_, __) => CustomPaint(
                      painter: _IntroPainter(
                        progress: _ambient.value,
                        reveal: _reveal.value,
                        particles: _particles,
                        center: center,
                        logoRadius: logoSize / 2,
                        gold: _gold,
                      ),
                    ),
                  ),
                  // Logo reveal.
                  Positioned(
                    left: center.dx - logoSize / 2,
                    top: center.dy - logoSize / 2,
                    width: logoSize,
                    height: logoSize,
                    child: AnimatedBuilder(
                      animation: _reveal,
                      builder: (_, child) {
                        final v = Curves.easeOutBack.transform(_reveal.value);
                        final opacity = Curves.easeIn
                            .transform(_reveal.value.clamp(0.0, 1.0));
                        return Opacity(
                          opacity: opacity,
                          child: Transform.scale(
                            scale: 0.7 + 0.3 * v,
                            child: child,
                          ),
                        );
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _gold.withOpacity(0.35),
                              blurRadius: 40,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const ClipOval(
                          child: Image(
                            image: AssetImage('assets/images/aya_logo.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Tagline.
                  Positioned(
                    left: 24,
                    right: 24,
                    top: center.dy + logoSize / 2 + 30,
                    child: AnimatedBuilder(
                      animation: _reveal,
                      builder: (_, __) {
                        final t =
                            ((_reveal.value - 0.55) / 0.45).clamp(0.0, 1.0);
                        return Opacity(
                          opacity: t,
                          child: Transform.translate(
                            offset: Offset(0, 12 * (1 - t)),
                            child: Column(
                              children: [
                                Text(
                                  'SREE ARADHANA YOUTH ASSOCIATION',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.6,
                                    color: Colors.white.withOpacity(0.92),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Connecting Members Digitally',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    letterSpacing: 0.5,
                                    color: _gold.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Particle {
  _Particle(this.x, this.y, this.radius, this.speed, this.phase, this.drift);

  final double x; // 0..1 base horizontal
  final double y; // 0..1 base vertical
  final double radius; // px
  final double speed; // vertical drift per ambient cycle
  final double phase; // twinkle phase
  final double drift; // horizontal sway factor

  factory _Particle.random(math.Random r) => _Particle(
        r.nextDouble(),
        r.nextDouble(),
        0.6 + r.nextDouble() * 2.0,
        0.3 + r.nextDouble() * 0.9,
        r.nextDouble() * math.pi * 2,
        0.4 + r.nextDouble() * 1.2,
      );
}

class _IntroPainter extends CustomPainter {
  _IntroPainter({
    required this.progress,
    required this.reveal,
    required this.particles,
    required this.center,
    required this.logoRadius,
    required this.gold,
  });

  final double progress; // 0..1 looping
  final double reveal; // 0..1 one-shot
  final List<_Particle> particles;
  final Offset center;
  final double logoRadius;
  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;
    final appear = Curves.easeOut.transform(reveal.clamp(0.0, 1.0));

    // Soft radial glow behind the logo.
    final glowR = size.width * (0.55 + 0.04 * math.sin(t));
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          gold.withOpacity(0.22 * appear),
          gold.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: glowR));
    canvas.drawCircle(center, glowR, glowPaint);

    // Light rays radiating from the logo, slowly rotating.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(t * 0.08);
    final rayLen = size.width * 0.75;
    final rayPaint = Paint()..color = gold.withOpacity(0.05 * appear);
    const rays = 14;
    for (var i = 0; i < rays; i++) {
      canvas.rotate(2 * math.pi / rays);
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(-rayLen * 0.04, rayLen)
        ..lineTo(rayLen * 0.04, rayLen)
        ..close();
      canvas.drawPath(path, rayPaint);
    }
    canvas.restore();

    // Drifting, twinkling particles.
    for (final p in particles) {
      final py = ((p.y - progress * p.speed) % 1.0 + 1.0) % 1.0;
      final px = p.x + 0.02 * math.sin(t * p.drift + p.phase);
      final twinkle = 0.25 + 0.55 * ((math.sin(t * 2 + p.phase) + 1) / 2);
      final paint = Paint()
        ..color = gold.withOpacity(twinkle * (0.35 + 0.65 * appear));
      canvas.drawCircle(
          Offset(px * size.width, py * size.height), p.radius, paint);
    }

    // Expanding ring on reveal.
    if (reveal < 1.0) {
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = gold.withOpacity((1 - appear) * 0.5);
      canvas.drawCircle(center, logoRadius * (1 + 1.7 * appear), ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _IntroPainter old) =>
      old.progress != progress || old.reveal != reveal;
}
