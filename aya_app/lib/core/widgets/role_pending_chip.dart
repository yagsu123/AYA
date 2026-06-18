import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Amber "Pending verification" chip — shown wherever a role is displayed
/// while role_status == 'pending'.
class RolePendingChip extends StatelessWidget {
  const RolePendingChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.amberLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.amber.withOpacity(0.4)),
      ),
      child: Text(
        'Pending verification',
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.amberDark,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
