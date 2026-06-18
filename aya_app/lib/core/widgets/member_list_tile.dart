import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/admin_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Row for the admin member list: avatar · mobile · joined date · status toggle.
class MemberListTile extends StatelessWidget {
  const MemberListTile({
    super.key,
    required this.member,
    required this.onToggle,
    this.onDelete,
  });

  final AdminMember member;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onDelete;

  static const _avatarColors = [
    AppColors.primary, AppColors.purple, AppColors.amber,
    AppColors.success, AppColors.danger,
  ];

  @override
  Widget build(BuildContext context) {
    final color = _avatarColors[member.id % _avatarColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Coloured avatar with first 2 digits of mobile
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.15),
            child: Text(
              member.mobile.substring(0, 2),
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(member.mobile,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(width: 6),
                    // Status dot
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: member.isActive ? AppColors.success : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text('Joined ${Formatters.date(member.createdAt)}',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11, color: AppColors.textMuted)),
                    if (member.role != 'member') ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          member.role[0].toUpperCase() + member.role.substring(1),
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 10, fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          PlatformSwitch(
            value: member.isActive,
            activeColor: AppColors.success,
            onChanged: onToggle,
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 20, color: AppColors.danger),
              tooltip: 'Delete member',
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
