import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/event_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/member_avatar.dart';
import '../../../core/widgets/vibhag_visuals.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Agenda-style event row: a colour date-rail on the left (with the date range
/// for multi-day events), the vibhag pill, time/venue, and overlapping labarthi
/// avatars. Shared by the Events list and the per-vibhag screens.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.showVibhag = true,
  });

  final AppEvent event;
  final VoidCallback onTap;
  final bool showVibhag;

  String? get _rangeText {
    if (!event.isMultiDay) return null;
    final s = event.date;
    final e = event.endDate!;
    return s.month == e.month
        ? '${s.day}–${e.day} ${_months[s.month - 1]}'
        : '${s.day} ${_months[s.month - 1]} – ${e.day} ${_months[e.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = VibhagVisuals.color(event.vibhagColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DateRail(event: event, accent: accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (showVibhag) _vibhagChip(accent),
                            if (event.isMultiDay)
                              _tag(Icons.calendar_month_rounded,
                                  '${event.dayCount} days', accent),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            if (_rangeText != null)
                              _meta(Icons.event_rounded, _rangeText!),
                            if (event.time != null)
                              _meta(Icons.schedule_rounded, event.time!),
                            if (event.venue != null && event.venue!.isNotEmpty)
                              _meta(Icons.place_outlined, event.venue!),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _labarthiRow(),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _labarthiRow() {
    if (event.labarthiCount == 0) {
      return Row(
        children: [
          const Icon(Icons.volunteer_activism_outlined,
              size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text('No labarthi yet',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5, color: AppColors.textMuted)),
        ],
      );
    }
    final names = event.labarthiPreview.take(3).toList();
    return Row(
      children: [
        SizedBox(
          width: names.isEmpty ? 0 : 22.0 + (names.length - 1) * 15,
          height: 24,
          child: Stack(
            children: [
              for (var i = 0; i < names.length; i++)
                Positioned(
                  left: i * 15.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: MemberAvatar(name: names[i], radius: 11),
                  ),
                ),
            ],
          ),
        ),
        if (names.isNotEmpty) const SizedBox(width: 8),
        Text('${event.labarthiCount} labarthi',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _vibhagChip(Color accent) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(VibhagVisuals.icon(event.vibhagIcon), size: 13, color: accent),
            const SizedBox(width: 4),
            Text(event.vibhagName,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, fontWeight: FontWeight.w700, color: accent)),
          ],
        ),
      );

  Widget _tag(IconData icon, String text, Color accent) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: accent),
            const SizedBox(width: 4),
            Text(text,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5, fontWeight: FontWeight.w700, color: accent)),
          ],
        ),
      );

  Widget _meta(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: AppColors.textMuted)),
          ),
        ],
      );
}

class _DateRail extends StatelessWidget {
  const _DateRail({required this.event, required this.accent});
  final AppEvent event;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final d = event.date;
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accent.withOpacity(0.78)],
        ),
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_months[d.month - 1].toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Colors.white.withOpacity(0.9))),
          Text('${d.day}',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
          if (event.isMultiDay)
            Text('+${event.dayCount - 1}d',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.85)))
          else
            Text('${d.year}',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 9, color: Colors.white.withOpacity(0.8))),
        ],
      ),
    );
  }
}
