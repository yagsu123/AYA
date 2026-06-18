import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/aya_logo.dart';

/// Decorative community card — fills the dashboard tail with the AYA
/// identity: logo mark, tagline and member count, over subtle arc motifs.
class CommunityBanner extends StatelessWidget {
  const CommunityBanner(
      {super.key, required this.tagline, required this.membersCount});

  final String tagline;
  final int membersCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF3DC), Color(0xFFFFFBF2)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomPaint(
        painter: _ArcsPainter(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const AyaLogo(size: 48, onDark: false),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aradhana Youth Association',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(tagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5, color: AppColors.amberDark)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.people_alt_outlined,
                            size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text('$membersCount members strong',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArcsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.amber.withOpacity(0.18);
    final center = Offset(size.width + 6, size.height + 6);
    for (final r in [40.0, 62.0, 84.0, 106.0]) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: r),
          math.pi, math.pi / 2, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
