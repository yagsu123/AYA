import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/app_colors.dart';
import 'bento_tiles.dart';

/// Which living micro-scene a [SceneCard] renders.
enum SceneKind { events, gallery, vibhags, aes, admin }

/// A dashboard quick-access card whose visual is a small flat illustration
/// (layered pastel shapes + ambient motion) instead of a flat icon.
class SceneCard extends StatefulWidget {
  const SceneCard({
    super.key,
    required this.kind,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final SceneKind kind;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<SceneCard> createState() => _SceneCardState();
}

class _SceneCardState extends State<SceneCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(seconds: 7))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: bentoBox(color: AppColors.surface),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _tint(widget.accent, 0.88),
                      _tint(widget.accent, 0.96),
                    ],
                  ),
                ),
                // Plays assets/lottie/<kind>.json if you drop one in;
                // otherwise falls back to the hand-painted ambient scene.
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Lottie.asset(
                    'assets/lottie/${widget.kind.name}.json',
                    fit: BoxFit.contain,
                    repeat: true,
                    errorBuilder: (_, __, ___) => AnimatedBuilder(
                      animation: _c,
                      builder: (_, __) => CustomPaint(
                        size: Size.infinite,
                        painter: _painterFor(widget.kind, _c.value, widget.accent),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration:
                        BoxDecoration(color: widget.accent, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lighten [c] toward white by [amt] (0 = full colour, 1 = white).
Color _tint(Color c, double amt) => Color.lerp(c, Colors.white, amt)!;

double _wave(double t, [double speed = 1, double phase = 0]) =>
    math.sin((t * speed) * 2 * math.pi + phase);

CustomPainter _painterFor(SceneKind kind, double t, Color accent) {
  switch (kind) {
    case SceneKind.events:
      return _EventsScene(t, accent);
    case SceneKind.gallery:
      return _GalleryScene(t, accent);
    case SceneKind.vibhags:
      return _VibhagsScene(t, accent);
    case SceneKind.aes:
      return _AesScene(t, accent);
    case SceneKind.admin:
      return _AdminScene(t, accent);
  }
}

abstract class _Scene extends CustomPainter {
  _Scene(this.t, this.accent);
  final double t;
  final Color accent;

  @override
  bool shouldRepaint(covariant _Scene old) => old.t != t || old.accent != accent;
}

/// Flat calendar: layered cards, accent header, white date tile, a soft
/// floating sun/badge above.
class _EventsScene extends _Scene {
  _EventsScene(super.t, super.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2 + 2;
    final cw = size.width * 0.5, ch = size.height * 0.6;
    final float = _wave(t, 1) * 2.0;

    canvas.save();
    canvas.translate(0, float);
    final l = cx - cw / 2, top = cy - ch / 2;
    // Binding tabs poking above the calendar (reads as a calendar at a glance).
    final tabPaint = Paint()..color = _tint(accent, 0.35);
    canvas.drawRRect(
        RRect.fromLTRBR(l + cw * 0.26, top - 7, l + cw * 0.34, top + 3, const Radius.circular(3)),
        tabPaint);
    canvas.drawRRect(
        RRect.fromLTRBR(l + cw * 0.66, top - 7, l + cw * 0.74, top + 3, const Radius.circular(3)),
        tabPaint);
    // Back card (peeking, mid tone).
    canvas.drawRRect(
        RRect.fromLTRBR(l + 7, top - 5, l + cw + 7, top + ch - 5, const Radius.circular(11)),
        Paint()..color = _tint(accent, 0.30));
    // Front card (light).
    canvas.drawRRect(
        RRect.fromLTRBR(l, top, l + cw, top + ch, const Radius.circular(11)),
        Paint()..color = _tint(accent, 0.62));
    // Header band.
    canvas.drawRRect(
        RRect.fromLTRBAndCorners(l, top, l + cw, top + ch * 0.34,
            topLeft: const Radius.circular(11), topRight: const Radius.circular(11)),
        Paint()..color = accent);
    // White date tile.
    canvas.drawRRect(
        RRect.fromLTRBR(cx - cw * 0.17, top + ch * 0.46, cx + cw * 0.17, top + ch * 0.84,
            const Radius.circular(6)),
        Paint()..color = Colors.white);
    canvas.restore();

    // Floating soft sun / badge.
    final d = _wave(t, 0.7) * 3;
    final c = Offset(cx + cw * 0.52, cy - ch * 0.52 + d);
    canvas.drawCircle(c, 8, Paint()..color = _tint(AppColors.amber, 0.55));
    canvas.drawCircle(c, 5, Paint()..color = AppColors.amber);
  }
}

/// Flat photo stack: layered pastel frames, a cream front photo with a soft
/// sun + hill, gently floating.
class _GalleryScene extends _Scene {
  _GalleryScene(super.t, super.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2 + 2;
    final pw = size.width * 0.44, ph = size.height * 0.52;

    void frame(double dx, double dy, double angle, Color fill) {
      canvas.save();
      canvas.translate(cx + dx, cy + dy);
      canvas.rotate(angle);
      canvas.drawRRect(
          RRect.fromLTRBR(-pw / 2, -ph / 2, pw / 2, ph / 2, const Radius.circular(7)),
          Paint()..color = fill);
      canvas.restore();
    }

    frame(-size.width * 0.11, 5, -0.18, _tint(accent, 0.25));
    frame(size.width * 0.08, 3, 0.14, _tint(accent, 0.45));

    // Front photo (floats), cream with soft sun + hill.
    final float = _wave(t, 1) * 2.2;
    canvas.save();
    canvas.translate(cx, cy - 2 + float);
    final r = RRect.fromLTRBR(-pw / 2, -ph / 2, pw / 2, ph / 2, const Radius.circular(7));
    canvas.drawRRect(r, Paint()..color = const Color(0xFFFFF6EF));
    canvas.save();
    canvas.clipRRect(r);
    canvas.drawCircle(Offset(pw * 0.16, -ph * 0.1), ph * 0.16,
        Paint()..color = _tint(AppColors.amber, 0.25));
    final hill = Path()
      ..moveTo(-pw / 2, ph / 2)
      ..lineTo(-pw * 0.08, -ph * 0.04)
      ..lineTo(pw * 0.24, ph / 2)
      ..close();
    canvas.drawPath(hill, Paint()..color = _tint(accent, 0.35));
    final hill2 = Path()
      ..moveTo(pw * 0.0, ph / 2)
      ..lineTo(pw * 0.32, -ph * 0.02)
      ..lineTo(pw / 2, ph / 2)
      ..close();
    canvas.drawPath(hill2, Paint()..color = _tint(accent, 0.15));
    canvas.restore();
    canvas.restore();
  }
}

/// Flat community: a soft rounded backdrop with overlapping breathing circles
/// (departments) — an ecosystem at a glance.
class _VibhagsScene extends _Scene {
  _VibhagsScene(super.t, super.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2 + 2;
    // Soft rounded backdrop.
    final bg = RRect.fromLTRBR(cx - size.width * 0.31, cy - size.height * 0.31,
        cx + size.width * 0.31, cy + size.height * 0.31, const Radius.circular(16));
    canvas.drawRRect(bg, Paint()..color = _tint(accent, 0.62));

    final r = size.height * 0.20;
    final blobs = [
      [Offset(cx - size.width * 0.09, cy - size.height * 0.03), accent, 0.0],
      [Offset(cx + size.width * 0.10, cy - size.height * 0.09), AppColors.amber, 1.0],
      [Offset(cx + size.width * 0.02, cy + size.height * 0.11), AppColors.success, 2.0],
    ];
    for (final b in blobs) {
      final pos = b[0] as Offset;
      final col = b[1] as Color;
      final phase = b[2] as double;
      final breathe = 1 + 0.06 * _wave(t, 1, phase);
      // Two flat tones — soft halo + solid core (clean, not bubbly).
      canvas.drawCircle(pos, r * breathe, Paint()..color = _tint(col, 0.4));
      canvas.drawCircle(pos, r * 0.62 * breathe, Paint()..color = col);
    }
  }
}

/// Flat analytics card: a light panel with breathing rounded bars and a soft
/// floating data marker.
class _AesScene extends _Scene {
  _AesScene(super.t, super.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2 + 2;
    final pw = size.width * 0.6, ph = size.height * 0.62;
    final l = cx - pw / 2, top = cy - ph / 2;

    // Back + front panel.
    canvas.drawRRect(
        RRect.fromLTRBR(l + 6, top - 5, l + pw + 6, top + ph - 5, const Radius.circular(11)),
        Paint()..color = _tint(accent, 0.30));
    canvas.drawRRect(
        RRect.fromLTRBR(l, top, l + pw, top + ph, const Radius.circular(11)),
        Paint()..color = _tint(accent, 0.62));

    // Breathing bars.
    final baseY = top + ph - 8;
    const n = 3;
    final innerW = pw - 24;
    final gap = innerW / n;
    final barW = gap * 0.52;
    for (var i = 0; i < n; i++) {
      final base = 0.4 + 0.18 * i;
      final hh = (base + 0.12 * ((_wave(t, 1, i.toDouble()) + 1) / 2)) * (ph * 0.6);
      final x = l + 12 + gap * i + (gap - barW) / 2;
      canvas.drawRRect(
          RRect.fromLTRBR(x, baseY - hh, x + barW, baseY, const Radius.circular(4)),
          Paint()..color = i == n - 1 ? accent : _tint(accent, 0.2));
    }

    // Floating data marker.
    final d = _wave(t, 0.8) * 3;
    final mc = Offset(l + pw - 8, top + 8 + d);
    canvas.drawCircle(mc, 7, Paint()..color = _tint(AppColors.amber, 0.5));
    canvas.drawCircle(mc, 4, Paint()..color = AppColors.amber);
  }
}

/// Flat shield with a soft layer and white check, plus a breathing aura.
class _AdminScene extends _Scene {
  _AdminScene(super.t, super.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.4, cy = size.height / 2 + 1;
    final s = math.min(size.width, size.height) * 0.34;

    Path shield(double scale) {
      final ss = s * scale;
      return Path()
        ..moveTo(cx, cy - ss)
        ..lineTo(cx + ss * 0.8, cy - ss * 0.5)
        ..lineTo(cx + ss * 0.8, cy + ss * 0.18)
        ..quadraticBezierTo(cx + ss * 0.8, cy + ss * 0.85, cx, cy + ss)
        ..quadraticBezierTo(cx - ss * 0.8, cy + ss * 0.85, cx - ss * 0.8, cy + ss * 0.18)
        ..lineTo(cx - ss * 0.8, cy - ss * 0.5)
        ..close();
    }

    // Breathing aura.
    final pulse = 0.5 + 0.5 * ((_wave(t, 0.8) + 1) / 2);
    canvas.drawPath(shield(1.22), Paint()..color = _tint(accent, 0.6).withOpacity(0.4 + 0.4 * pulse));
    canvas.drawPath(shield(1.0), Paint()..color = accent);
    // Check.
    final ck = Path()
      ..moveTo(cx - s * 0.3, cy)
      ..lineTo(cx - s * 0.05, cy + s * 0.28)
      ..lineTo(cx + s * 0.38, cy - s * 0.28);
    canvas.drawPath(ck, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white);

    // Toggle rows.
    final tx = size.width * 0.7;
    for (var i = 0; i < 2; i++) {
      final y = cy - s * 0.4 + i * (s * 0.8);
      canvas.drawRRect(
          RRect.fromLTRBR(tx, y - 4, tx + 18, y + 4, const Radius.circular(999)),
          Paint()..color = (i == 0 ? accent : _tint(accent, 0.55)));
      canvas.drawCircle(Offset(i == 0 ? tx + 14 : tx + 4, y), 3.4, Paint()..color = Colors.white);
    }
  }
}
