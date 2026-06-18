import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/dashboard_service.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/contact_actions.dart';
import '../../../core/widgets/animated_icons.dart';

/// Horizontal scroll of celebration cards (birthdays / anniversaries)
/// with a gradient cap and a WhatsApp wish button.
class CelebrationSection extends StatelessWidget {
  const CelebrationSection({
    super.key,
    required this.title,
    required this.entries,
    required this.subtitleBuilder,
    required this.whatsappMessage,
    this.icon = Icons.cake_outlined,
    this.accent = AppColors.amber,
  });

  final String title;
  final List<CelebrationEntry> entries;
  final String Function(CelebrationEntry) subtitleBuilder;
  final String whatsappMessage;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              PulseIcon(icon: icon, color: accent, size: 15, boxSize: 28),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ],
          ),
        ),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final e = entries[i];
              return Container(
                width: 150,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Gradient cap with overlapping avatar
                    SizedBox(
                      height: 64,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [accent, accent.withOpacity(0.6)],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0, right: 0, top: 16,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(2.5),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: CircleAvatar(
                                  radius: 21,
                                  backgroundColor: accent.withOpacity(0.15),
                                  backgroundImage: e.photoUrl != null
                                      ? CachedNetworkImageProvider(
                                          ProfileService.resolvePhotoUrl(
                                              e.photoUrl!))
                                      : null,
                                  child: e.photoUrl == null
                                      ? Text(
                                          e.name.isEmpty
                                              ? '?'
                                              : e.name[0].toUpperCase(),
                                          style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w800,
                                              color: accent))
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 2, 10, 10),
                      child: Column(
                        children: [
                          Text(e.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 1),
                          Text(
                            e.relation == 'spouse'
                                ? '${subtitleBuilder(e)} · spouse'
                                : e.relation == 'child'
                                    ? '${subtitleBuilder(e)} · child'
                                    : subtitleBuilder(e),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5, color: AppColors.textMuted)),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 32,
                            child: ElevatedButton.icon(
                              onPressed: e.mobile.isEmpty
                                  ? null
                                  : () => ContactActions.whatsapp(e.mobile,
                                      message: whatsappMessage),
                              icon: const Icon(Icons.chat, size: 13),
                              label: const Text('Wish'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999)),
                                textStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
