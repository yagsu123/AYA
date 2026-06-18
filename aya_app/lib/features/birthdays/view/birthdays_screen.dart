import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/occasions_service.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/contact_actions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/animated_icons.dart';

/// Birthdays & Anniversaries — segmented control on top,
/// Today / Upcoming tabs inside each segment.
class BirthdaysScreen extends StatefulWidget {
  const BirthdaysScreen({super.key, this.initialKind = 'birthdays'});

  final String initialKind;

  @override
  State<BirthdaysScreen> createState() => _BirthdaysScreenState();
}

class _BirthdaysScreenState extends State<BirthdaysScreen> {
  late String _kind = widget.initialKind; // birthdays | anniversaries

  bool get _isBirthday => _kind == 'birthdays';
  Color get _accent => _isBirthday ? AppColors.amber : AppColors.danger;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: AppColors.textPrimary),
          title: Text(_isBirthday ? 'Birthdays' : 'Anniversaries',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          bottom: TabBar(
            indicatorColor: _accent,
            indicatorWeight: 3,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w700),
            tabs: const [Tab(text: 'Today'), Tab(text: 'Upcoming')],
          ),
        ),
        body: Column(
          children: [
            // Segmented: Birthdays | Anniversaries
            Padding(
              padding: EdgeInsets.fromLTRB(Responsive.padding(context), 12,
                  Responsive.padding(context), 4),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _segment('Birthdays', Icons.cake_outlined, 'birthdays'),
                    _segment('Anniversaries', Icons.favorite_outline, 'anniversaries'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _OccasionList(
                      key: ValueKey('$_kind-today'),
                      kind: _kind, filter: 'today', accent: _accent),
                  _OccasionList(
                      key: ValueKey('$_kind-upcoming'),
                      kind: _kind, filter: 'upcoming', accent: _accent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segment(String label, IconData icon, String value) {
    final selected = _kind == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _kind = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? _accent.withOpacity(0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14,
                  color: selected ? _accent : AppColors.textMuted),
              const SizedBox(width: 6),
              Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.textPrimary : AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OccasionList extends StatefulWidget {
  const _OccasionList(
      {super.key, required this.kind, required this.filter, required this.accent});

  final String kind;
  final String filter;
  final Color accent;

  @override
  State<_OccasionList> createState() => _OccasionListState();
}

class _OccasionListState extends State<_OccasionList>
    with AutomaticKeepAliveClientMixin {
  late Future<List<Occasion>> _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _future = OccasionsService.instance
        .fetch(kind: widget.kind, filter: widget.filter, days: 365);
  }

  Future<void> _reload() async {
    setState(() {
      _future = OccasionsService.instance
          .fetch(kind: widget.kind, filter: widget.filter, days: 365);
    });
    await _future;
  }

  bool get _isBirthday => widget.kind == 'birthdays';

  String _subtitle(Occasion o) {
    if (widget.filter == 'today') {
      return _isBirthday ? 'Turns ${o.years} today' : '${o.years} years today';
    }
    final when = o.daysUntil == 1 ? 'Tomorrow' : 'In ${o.daysUntil} days';
    return _isBirthday ? '$when · turns ${o.years}' : '$when · ${o.years} years';
  }

  String? _relationLabel(Occasion o) {
    if (o.relation == 'spouse') return 'Spouse of ${o.via ?? 'member'}';
    if (o.relation == 'child') return 'Child of ${o.via ?? 'member'}';
    if (!_isBirthday && o.via != null) return 'With ${o.via}';
    return null;
  }

  void _addToCalendar(Occasion o) {
    final title = _isBirthday
        ? "${o.name}'s Birthday"
        : "${o.name}'s Anniversary";
    final event = Event(
      title: title,
      description: 'From Aradhana Youth Association',
      startDate: DateTime(o.nextOccurrence.year, o.nextOccurrence.month,
          o.nextOccurrence.day, 9),
      endDate: DateTime(o.nextOccurrence.year, o.nextOccurrence.month,
          o.nextOccurrence.day, 10),
      recurrence: Recurrence(frequency: Frequency.yearly),
    );
    Add2Calendar.addEvent2Cal(event);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final pad = Responsive.padding(context);

    return FutureBuilder<List<Occasion>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Could not load. Pull to retry.',
                    style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted)),
                TextButton(onPressed: _reload, child: const Text('Retry')),
              ],
            ),
          );
        }
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                Center(
                  child: PulseIcon(
                      icon: _isBirthday
                          ? Icons.cake_outlined
                          : Icons.favorite_outline,
                      color: AppColors.border,
                      size: 56),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    widget.filter == 'today'
                        ? (_isBirthday
                            ? 'No birthdays today'
                            : 'No anniversaries today')
                        : 'No upcoming dates found',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          );
        }

        // Group upcoming by date
        final groups = <String, List<Occasion>>{};
        for (final o in items) {
          final key = widget.filter == 'today'
              ? 'Today'
              : Formatters.date(o.nextOccurrence);
          groups.putIfAbsent(key, () => []).add(o);
        }

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: EdgeInsets.all(pad),
            children: [
              for (final entry in groups.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Text(entry.key.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          letterSpacing: 0.8, color: AppColors.textMuted)),
                ),
                for (final o in entry.value) _card(o),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _card(Occasion o) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: widget.accent.withOpacity(0.14),
            backgroundImage: o.photoUrl != null
                ? CachedNetworkImageProvider(
                    ProfileService.resolvePhotoUrl(o.photoUrl!))
                : null,
            child: o.photoUrl == null
                ? Text(o.name.isEmpty ? '?' : o.name[0].toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800, color: widget.accent))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                Text(_subtitle(o),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5, color: AppColors.textMuted)),
                if (_relationLabel(o) != null)
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(_relationLabel(o)!,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: widget.accent)),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Add to calendar',
            onPressed: () {
              _addToCalendar(o);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening calendar…')),
              );
            },
            icon: const Icon(Icons.event_available_outlined,
                size: 20, color: AppColors.primary),
          ),
          if (o.mobile.isNotEmpty)
            ElevatedButton(
              onPressed: () => ContactActions.whatsapp(
                o.mobile,
                message: _isBirthday
                    ? 'Happy Birthday from Aradhana Youth Association 🎉'
                    : 'Happy Anniversary from Aradhana Youth Association 🎉',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 34),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
                textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
              child: const Text('Wish'),
            ),
        ],
      ),
    );
  }
}
