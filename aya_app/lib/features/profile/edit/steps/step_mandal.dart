import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/role_pending_chip.dart';
import '../profile_edit_data.dart';

const mandalCategories = [
  'Sangeet', 'Seva', 'Aangi', 'Jeev Daya', 'Paryushan', 'Snatra Puja', 'General',
];

class StepMandal extends StatelessWidget {
  const StepMandal({super.key, required this.data, required this.onChanged});

  final ProfileEditData data;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        DropdownButtonFormField<String>(
          value: data.mandalCategory,
          decoration: const InputDecoration(
              labelText: 'Mandal category',
              prefixIcon: Icon(Icons.category_outlined, size: 20)),
          items: [
            for (final c in mandalCategories) DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged: (v) {
            data.mandalCategory = v;
            onChanged();
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: data.mandalPosition,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
              labelText: 'Mandal position',
              prefixIcon: Icon(Icons.badge_outlined, size: 20)),
        ),
        const SizedBox(height: 24),
        Text('ROLE',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11, fontWeight: FontWeight.w600,
                letterSpacing: 0.66, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        for (final role in const ['member', 'president', 'secretary'])
          RadioListTile<String>(
            value: role,
            groupValue: data.role,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Text(role[0].toUpperCase() + role.substring(1),
                    style: GoogleFonts.plusJakartaSans(fontSize: 14)),
                if (data.role == role && role != 'member' && data.roleStatus == 'pending') ...[
                  const SizedBox(width: 8),
                  const RolePendingChip(),
                ],
              ],
            ),
            onChanged: (v) {
              data.role = v!;
              onChanged();
            },
          ),
        if (data.role != 'member')
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.amberLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'President and Secretary roles require approval from an existing admin. '
              'Your role stays pending until approved.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: AppColors.amberDark, height: 1.5),
            ),
          ),
      ],
    );
  }
}
