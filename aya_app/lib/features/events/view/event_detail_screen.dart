import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/auth_service.dart' show AuthException;
import '../../../core/services/event_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/member_avatar.dart';
import '../../../core/widgets/vibhag_visuals.dart';
import '../events_provider.dart';
import '../widgets/assign_members_sheet.dart';
import '../widgets/event_form_sheet.dart';
import '../widgets/labarthi_form_sheet.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final int eventId;

  void _reload(WidgetRef ref) =>
      ref.read(eventDetailProvider(eventId).notifier).load();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(eventDetailProvider(eventId));
    final detail = state.detail;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text('Event',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
        actions: [
          if (detail != null && detail.canManage)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
              onSelected: (v) {
                if (v == 'edit') _edit(context, ref, detail.event);
                if (v == 'delete') _confirmDelete(context, ref, detail.event);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit event')),
                PopupMenuItem(value: 'delete', child: Text('Delete event')),
              ],
            ),
        ],
      ),
      body: state.loading && detail == null
          ? const Center(child: CircularProgressIndicator())
          : detail == null
              ? Center(
                  child: Text(state.error ?? 'Event not found.',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted)))
              : RefreshIndicator(
                  onRefresh: () async => _reload(ref),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      _header(context, detail.event),
                      const SizedBox(height: 12),
                      _calendarButton(context, detail.event),
                      const SizedBox(height: 16),
                      if (detail.event.description != null &&
                          detail.event.description!.isNotEmpty) ...[
                        _detailsCard(detail.event),
                        const SizedBox(height: 16),
                      ],
                      _AssignedSection(detail: detail, onChanged: () => _reload(ref)),
                      const SizedBox(height: 16),
                      _LabarthiSection(detail: detail, onChanged: () => _reload(ref)),
                    ],
                  ),
                ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, AppEvent event) async {
    final saved = await EventFormSheet.show(context, event: event);
    if (saved == true) _reload(ref);
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, AppEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete event'),
        content: Text('Delete "${event.name}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await EventService.instance.delete(event.id);
      if (context.mounted) context.pop();
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  // ---- Calendar -------------------------------------------------------------

  DateTime _at(DateTime day, String? hhmm, {int fallbackHour = 9}) {
    if (hhmm == null) return DateTime(day.year, day.month, day.day, fallbackHour);
    final parts = hhmm.split(':');
    return DateTime(day.year, day.month, day.day,
        int.tryParse(parts[0]) ?? 0, int.tryParse(parts[1]) ?? 0);
  }

  Future<void> _addToCalendar(BuildContext context, AppEvent event) async {
    final start = _at(event.date, event.time);
    final endDay = event.endDate ?? event.date;
    final end = event.endTime != null
        ? _at(endDay, event.endTime)
        : start.add(const Duration(hours: 2));

    // Preferred: hand off to the device calendar app (Google / Apple / Outlook).
    try {
      final added = await Add2Calendar.addEvent2Cal(Event(
        title: event.name,
        description: event.description ?? '${event.vibhagName} event',
        location: event.venue ?? '',
        startDate: start,
        endDate: end,
      ));
      if (added) return;
    } catch (_) {
      // fall through to the .ics fallback
    }
    // Fallback: share a standard .ics file (opens in any calendar app).
    await _shareIcs(context, event, start, end);
  }

  Future<void> _shareIcs(
      BuildContext context, AppEvent event, DateTime start, DateTime end) async {
    String two(int n) => n.toString().padLeft(2, '0');
    String stamp(DateTime d) =>
        '${d.year}${two(d.month)}${two(d.day)}T${two(d.hour)}${two(d.minute)}00';
    String esc(String s) =>
        s.replaceAll('\n', ' ').replaceAll(',', '\\,').replaceAll(';', '\\;');

    final ics = 'BEGIN:VCALENDAR\r\n'
        'VERSION:2.0\r\nPRODID:-//AYA//Events//EN\r\nCALSCALE:GREGORIAN\r\n'
        'BEGIN:VEVENT\r\n'
        'UID:aya-event-${event.id}@aradhanayouth\r\n'
        'DTSTART:${stamp(start)}\r\nDTEND:${stamp(end)}\r\n'
        'SUMMARY:${esc(event.name)}\r\n'
        'LOCATION:${esc(event.venue ?? '')}\r\n'
        'DESCRIPTION:${esc(event.description ?? '${event.vibhagName} event')}\r\n'
        'BEGIN:VALARM\r\nTRIGGER:-PT2H\r\nACTION:DISPLAY\r\n'
        'DESCRIPTION:Reminder\r\nEND:VALARM\r\n'
        'END:VEVENT\r\nEND:VCALENDAR\r\n';

    try {
      final dir = await getTemporaryDirectory();
      final safe = event.name.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');
      final file = File('${dir.path}/$safe.ics');
      await file.writeAsString(ics);
      // iPad requires an anchor rect for the share popover, or it crashes.
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/calendar')],
        text: 'Add "${event.name}" to your calendar',
        sharePositionOrigin:
            box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the calendar.')),
        );
      }
    }
  }

  Widget _calendarButton(BuildContext context, AppEvent event) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () => _addToCalendar(context, event),
        icon: const Icon(Icons.event_available_rounded, color: Colors.white),
        label: Text('Add to calendar',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  // ---- Header ---------------------------------------------------------------

  String _fmtTime(BuildContext context, String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0)
        .format(context);
  }

  String _dateText(AppEvent e) => e.isMultiDay
      ? '${Formatters.date(e.date)} – ${Formatters.date(e.endDate!)}  ·  ${e.dayCount} days'
      : Formatters.date(e.date);

  String? _timeText(BuildContext context, AppEvent e) {
    if (e.time == null) return null;
    final start = _fmtTime(context, e.time!);
    return e.endTime != null ? '$start – ${_fmtTime(context, e.endTime!)}' : start;
  }

  Widget _header(BuildContext context, AppEvent event) {
    final accent = VibhagVisuals.color(event.vibhagColor);
    final time = _timeText(context, event);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accent.withOpacity(0.82)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(VibhagVisuals.icon(event.vibhagIcon), size: 14, color: Colors.white),
                const SizedBox(width: 5),
                Text(event.vibhagName,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(event.name,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: Colors.white)),
          const SizedBox(height: 14),
          _row(event.isMultiDay
              ? Icons.calendar_month_rounded
              : Icons.calendar_today_rounded, _dateText(event)),
          if (time != null) ...[
            const SizedBox(height: 8),
            _row(Icons.schedule_rounded, time),
          ],
          if (event.venue != null && event.venue!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _row(Icons.place_outlined, event.venue!),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.95))),
          ),
        ],
      );

  Widget _detailsCard(AppEvent event) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Text(event.description!,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, height: 1.55, color: AppColors.textPrimary)),
          ],
        ),
      );
}

class _AssignedSection extends StatelessWidget {
  const _AssignedSection({required this.detail, required this.onChanged});

  final EventDetail detail;
  final VoidCallback onChanged;

  bool get _locked => detail.event.membersLocked;

  Future<void> _assign(BuildContext context) async {
    final saved = await AssignMembersSheet.show(
      context,
      eventId: detail.event.id,
      initialSelected: detail.assignments.map((a) => a.memberId).toSet(),
    );
    if (saved == true) onChanged();
  }

  Future<void> _toggleLock(BuildContext context) async {
    try {
      await EventService.instance.setMembersLock(detail.event.id, !_locked);
      onChanged();
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_2_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Assigned members',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const Spacer(),
              _statusChip(),
            ],
          ),
          const SizedBox(height: 12),

          // Edit / lock controls.
          Row(
            children: [
              if (detail.canEditMembers)
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _assign(context),
                    icon: const Icon(Icons.checklist_rounded, size: 18),
                    label: Text(detail.assignments.isEmpty ? 'Assign members' : 'Edit members',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                  ),
                ),
              if (detail.isAdmin) ...[
                if (detail.canEditMembers) const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _locked ? AppColors.success : AppColors.danger,
                      side: BorderSide(
                          color: _locked ? AppColors.success : AppColors.danger),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _toggleLock(context),
                    icon: Icon(_locked ? Icons.lock_open_rounded : Icons.lock_rounded,
                        size: 18),
                    label: Text(_locked ? 'Unlock' : 'Lock',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ),

          if (!detail.canEditMembers && !detail.isAdmin)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Locked by an admin — read-only.',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: AppColors.textMuted)),
            ),

          const SizedBox(height: 12),
          if (detail.assignments.isEmpty)
            Text('No members assigned yet.',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: AppColors.textMuted))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in detail.assignments)
                  Container(
                    padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MemberAvatar(name: a.name, photoUrl: a.photoUrl, radius: 13),
                        const SizedBox(width: 8),
                        Text(a.name,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
              ],
            ),

          // Audit line.
          if (_locked && detail.event.lockedByName != null) ...[
            const SizedBox(height: 12),
            Text(
              'Locked by ${detail.event.lockedByName}'
              '${detail.event.lockedAt != null ? ' · ${Formatters.date(detail.event.lockedAt!)}' : ''}',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusChip() {
    late final IconData icon;
    late final String label;
    late final Color color;
    if (_locked) {
      icon = Icons.lock_rounded;
      label = 'Locked';
      color = AppColors.danger;
    } else if (detail.assignments.isNotEmpty) {
      icon = Icons.hourglass_top_rounded;
      label = 'Pending';
      color = AppColors.amber;
    } else {
      icon = Icons.lock_open_rounded;
      label = 'Open';
      color = AppColors.success;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _LabarthiSection extends StatelessWidget {
  const _LabarthiSection({required this.detail, required this.onChanged});

  final EventDetail detail;
  final VoidCallback onChanged;

  Future<void> _add(BuildContext context) async {
    final done = await LabarthiFormSheet.show(context, eventId: detail.event.id);
    if (done == true) onChanged();
  }

  Future<void> _remove(BuildContext context, Labarthi l) async {
    try {
      await EventService.instance.removeLabarthi(detail.event.id, l.id);
      onChanged();
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  static String _money(double amount) =>
      amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.volunteer_activism_rounded,
                  size: 18, color: AppColors.amber),
              const SizedBox(width: 8),
              Text('Labarthi',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const Spacer(),
              Text('${detail.labarthis.length}',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          if (detail.canManage)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.amber,
                  side: const BorderSide(color: AppColors.amber),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _add(context),
                icon: const Icon(Icons.add_rounded),
                label: Text('Add labarthi',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              ),
            ),
          if (detail.labarthis.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('No labarthi recorded yet.',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, color: AppColors.textMuted)),
            )
          else ...[
            const SizedBox(height: 6),
            for (final l in detail.labarthis) _tile(context, l),
          ],
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, Labarthi l) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          MemberAvatar(name: l.name, radius: 18, color: AppColors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.name,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                // Amount is shown only to authorised users (admins).
                if (detail.canViewAmounts && l.amount != null)
                  Text('₹ ${_money(l.amount!)}',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success)),
                if (l.note != null && l.note!.isNotEmpty)
                  Text(l.note!,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (detail.canManage)
            IconButton(
              onPressed: () => _remove(context, l),
              icon: const Icon(Icons.close_rounded,
                  size: 18, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}
