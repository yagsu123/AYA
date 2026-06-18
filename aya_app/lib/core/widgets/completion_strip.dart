import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Amber profile-completion nudge. Hidden when pct >= 100.
class CompletionStrip extends StatelessWidget {
  const CompletionStrip({super.key, required this.pct, required this.label});

  final int pct;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (pct >= 100) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push('/profile/complete'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.amberLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.amber.withOpacity(0.35)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.assignment_ind_outlined,
                    size: 18, color: AppColors.amberDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.amberDark)),
                ),
                Text('$pct%',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.amberDark)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: pct / 100,
                minHeight: 6,
                backgroundColor: Colors.white,
                valueColor: const AlwaysStoppedAnimation(AppColors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
