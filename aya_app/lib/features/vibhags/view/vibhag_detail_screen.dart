import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/event_service.dart';
import '../../../core/services/vibhag_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/member_avatar.dart';
import '../../../core/widgets/vibhag_visuals.dart';
import '../../events/widgets/event_card.dart';
import '../../events/widgets/event_form_sheet.dart';
import '../vibhags_provider.dart';
import '../widgets/manage_heads_sheet.dart';

class VibhagDetailScreen extends ConsumerWidget {
  const VibhagDetailScreen({super.key, required this.type});

  final String type;

  void _reload(WidgetRef ref) => ref.read(vibhagDetailProvider(type).notifier).load();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vibhagDetailProvider(type));
    final isAdmin = ref.watch(vibhagsProvider).data?.isAdmin ?? false;
    final detail = state.detail;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text(detail?.vibhag.name ?? 'Vibhag',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
      ),
      floatingActionButton: (detail?.canManage ?? false)
          ? FloatingActionButton.extended(
              backgroundColor: VibhagVisuals.color(detail!.vibhag.color),
              onPressed: () => _createEvent(context, ref, detail.vibhag),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text('New event',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700, color: Colors.white)),
            )
          : null,
      body: state.loading && detail == null
          ? const Center(child: CircularProgressIndicator())
          : detail == null
              ? Center(
                  child: Text(state.error ?? 'Could not load vibhag.',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted)))
              : RefreshIndicator(
                  onRefresh: () async => _reload(ref),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    children: [
                      _header(detail.vibhag),
                      const SizedBox(height: 18),
                      _headsSection(context, ref, detail, isAdmin),
                      const SizedBox(height: 20),
                      _eventsSection('Upcoming events', detail.upcoming, ref, context,
                          emptyText: 'No upcoming events.'),
                      if (detail.past.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _eventsSection('Past events', detail.past, ref, context),
                      ],
                    ],
                  ),
                ),
    );
  }

  Future<void> _createEvent(BuildContext context, WidgetRef ref, Vibhag vibhag) async {
    final saved = await EventFormSheet.show(context,
        lockedVibhagType: vibhag.type, manageableVibhags: [vibhag]);
    if (saved == true) _reload(ref);
  }

  Widget _header(Vibhag vibhag) {
    final accent = VibhagVisuals.color(vibhag.color);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accent.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(VibhagVisuals.icon(vibhag.icon), color: Colors.white, size: 28),
          ),
          const SizedBox(height: 14),
          Text(vibhag.name,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
          if (vibhag.description != null && vibhag.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(vibhag.description!,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.95))),
          ],
        ],
      ),
    );
  }

  Widget _headsSection(
      BuildContext context, WidgetRef ref, VibhagDetail detail, bool isAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Vibhag heads',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const Spacer(),
            if (isAdmin)
              TextButton.icon(
                onPressed: () => ManageHeadsSheet.show(
                  context,
                  vibhagType: detail.vibhag.type,
                  vibhagName: detail.vibhag.name,
                  heads: detail.heads,
                  onChanged: () => _reload(ref),
                ),
                icon: const Icon(Icons.manage_accounts_rounded, size: 18),
                label: Text('Manage',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        if (detail.heads.isEmpty)
          Text('No heads appointed yet.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.textMuted))
        else
          for (final h in detail.heads)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  MemberAvatar(name: h.fullName, photoUrl: h.photoUrl, radius: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(h.fullName,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ),
                  const Icon(Icons.workspace_premium_rounded,
                      size: 16, color: AppColors.amber),
                ],
              ),
            ),
      ],
    );
  }

  Widget _eventsSection(
      String title, List<AppEvent> events, WidgetRef ref, BuildContext context,
      {String? emptyText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        if (events.isEmpty && emptyText != null)
          Text(emptyText,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.textMuted))
        else
          for (final event in events)
            EventCard(
              event: event,
              showVibhag: false,
              onTap: () => context
                  .push('/events/${event.id}')
                  .then((_) => _reload(ref)),
            ),
      ],
    );
  }
}
