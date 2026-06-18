import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/dashboard_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_icons.dart';
import '../../../core/utils/formatters.dart';

const bentoRadius = 20.0;

BoxDecoration bentoBox({Color? color, Gradient? gradient}) => BoxDecoration(
      color: color,
      gradient: gradient,
      borderRadius: BorderRadius.circular(bentoRadius),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.05),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );

/// Large blue hero tile — next event (or a Jai Jinendra tile when none).
class EventHeroTile extends StatelessWidget {
  const EventHeroTile({super.key, this.event, required this.onTap});

  final NextEvent? event;
  final VoidCallback onTap;

  static const _icons = {
    'paryushan': Icons.local_fire_department_rounded,
    'sangeet': Icons.music_note_rounded,
    'snatra': Icons.spa_rounded,
    'seva': Icons.volunteer_activism_rounded,
    'jeev_daya': Icons.eco_rounded,
    'aangi': Icons.checkroom_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final e = event;
    final daysLeft = e == null
        ? 0
        : e.date.difference(DateTime.now()).inDays + 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: bentoBox(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2992D6), Color(0xFF1A6FAA)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: e == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FlameIcon(size: 30),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Aradhana Youth',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 17, fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ),
                  const SizedBox(height: 2),
                  Text('No upcoming events',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: Colors.white70)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_icons[e.vibhagType] ?? Icons.event_rounded,
                          size: 16, color: const Color(0xFFFFD37E)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('NEXT EVENT',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5, fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: Colors.white.withOpacity(0.75))),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(e.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 17, fontWeight: FontWeight.w800,
                          height: 1.2, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    '${Formatters.date(e.date)}'
                    '${e.venue == null ? '' : ' · ${e.venue}'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: Colors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      daysLeft <= 0
                          ? 'Today'
                          : daysLeft == 1
                              ? 'Tomorrow'
                              : 'In $daysLeft days',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5, fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Small stat tile: icon, number, label.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: bentoBox(color: AppColors.surface),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(value,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16, fontWeight: FontWeight.w800,
                            height: 1.1, color: AppColors.textPrimary)),
                  ),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wide amber completion tile.
class CompletionTile extends StatelessWidget {
  const CompletionTile(
      {super.key, required this.pct, required this.label, required this.onTap});

  final int pct;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (pct >= 100) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: bentoBox(color: AppColors.amberLight),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.assignment_ind_outlined,
                size: 18, color: AppColors.amberDark),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: AppColors.amberDark)),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      minHeight: 5,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation(AppColors.amber),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text('$pct%',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15, fontWeight: FontWeight.w800,
                    color: AppColors.amberDark)),
          ],
        ),
      ),
    );
  }
}

/// Compact square quick tile: icon + label.
class QuickTile extends StatelessWidget {
  const QuickTile({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: bentoBox(color: AppColors.surface),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(height: 6),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
