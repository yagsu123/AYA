import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../utils/contact_actions.dart';

class ContactAction {
  const ContactAction(this.icon, this.label, this.color, this.onTap);
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

/// Row of circular action buttons: Call · SMS · WhatsApp · Email · Save.
class ContactActionRow extends StatelessWidget {
  const ContactActionRow({
    super.key,
    required this.name,
    this.mobile,
    this.email,
    this.compact = false,
  });

  final String name;
  final String? mobile;
  final String? email;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final actions = <ContactAction>[
      if (mobile != null && mobile!.isNotEmpty) ...[
        ContactAction(Icons.call, 'Call', const Color(0xFF10B981),
            () => ContactActions.call(mobile!)),
        ContactAction(Icons.sms_outlined, 'SMS', AppColors.primary,
            () => ContactActions.sms(mobile!)),
        ContactAction(Icons.chat, 'WhatsApp', const Color(0xFF25D366),
            () => ContactActions.whatsapp(mobile!)),
      ],
      if (email != null && email!.isNotEmpty)
        ContactAction(Icons.mail_outline, 'Email', AppColors.danger,
            () => ContactActions.email(email!)),
      if (mobile != null && mobile!.isNotEmpty)
        ContactAction(Icons.person_add_alt_1_outlined, 'Save', AppColors.amber,
            () => ContactActions.saveContact(name: name, mobile: mobile!)),
    ];

    if (actions.isEmpty) return const SizedBox.shrink();

    final size = compact ? 36.0 : 46.0;
    final iconSize = compact ? 17.0 : 20.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final a in actions)
          GestureDetector(
            onTap: a.onTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: a.color.withOpacity(0.10),
                  ),
                  child: Icon(a.icon, size: iconSize, color: a.color),
                ),
                const SizedBox(height: 4),
                Text(a.label,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: compact ? 9 : 10.5,
                        color: compact
                            ? AppColors.textMuted
                            : AppColors.textPrimary)),
              ],
            ),
          ),
      ],
    );
  }
}
