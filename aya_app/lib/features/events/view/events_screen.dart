import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/vibhag_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/vibhag_visuals.dart';
import '../../vibhags/vibhags_provider.dart';
import '../events_provider.dart';
import '../widgets/event_card.dart';
import '../widgets/event_form_sheet.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventsProvider.notifier).load();
    });
  }

  Future<void> _createEvent(VibhagList vibhags) async {
    // Any member may create an event for any vibhag (project policy).
    final saved =
        await EventFormSheet.show(context, manageableVibhags: vibhags.items);
    if (saved == true) ref.read(eventsProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventsProvider);
    final vibhagsState = ref.watch(vibhagsProvider);
    final vibhags = vibhagsState.data;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text('Events',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
      ),
      floatingActionButton: (vibhags != null)
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              onPressed: () => _createEvent(vibhags!),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text('New event',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700, color: Colors.white)),
            )
          : null,
      body: Column(
        children: [
          _scopeToggle(state.scope),
          if (vibhags != null) _vibhagFilter(vibhags, state.vibhagType),
          Expanded(child: _list(state)),
        ],
      ),
    );
  }

  Widget _scopeToggle(String scope) {
    Widget seg(String label, String value) {
      final selected = scope == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => ref.read(eventsProvider.notifier).setScope(value),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.textMuted)),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
          Responsive.padding(context), 12, Responsive.padding(context), 4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [seg('Upcoming', 'upcoming'), seg('Past', 'past')]),
      ),
    );
  }

  Widget _vibhagFilter(VibhagList vibhags, String? selectedType) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context)),
        children: [
          _filterChip('All', null, selectedType == null, AppColors.primary, null),
          for (final v in vibhags.items)
            _filterChip(v.name, v.type, selectedType == v.type,
                VibhagVisuals.color(v.color), VibhagVisuals.icon(v.icon)),
        ],
      ),
    );
  }

  Widget _filterChip(
      String label, String? type, bool selected, Color accent, IconData? icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => ref.read(eventsProvider.notifier).setVibhag(type),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? accent.withOpacity(0.14) : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: selected ? accent : AppColors.border,
                width: selected ? 1.5 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: accent),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: selected ? accent : AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(EventsState state) {
    if (state.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return _message(Icons.cloud_off_rounded, state.error!);
    }
    if (state.items.isEmpty) {
      return _message(
          Icons.event_busy_rounded,
          state.scope == 'past'
              ? 'No past events yet.'
              : 'No upcoming events scheduled.');
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(eventsProvider.notifier).load(),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(Responsive.padding(context), 10,
            Responsive.padding(context), 90),
        itemCount: state.items.length,
        itemBuilder: (_, i) {
          final event = state.items[i];
          return EventCard(
            event: event,
            onTap: () => context
                .push('/events/${event.id}')
                .then((_) => ref.read(eventsProvider.notifier).load()),
          );
        },
      ),
    );
  }

  Widget _message(IconData icon, String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5, color: AppColors.textMuted)),
            ],
          ),
        ),
      );
}
