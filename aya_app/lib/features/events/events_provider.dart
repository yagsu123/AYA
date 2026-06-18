import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart' show AuthException;
import '../../core/services/event_service.dart';

class EventsState {
  const EventsState({
    this.loading = false,
    this.scope = 'upcoming',
    this.vibhagType,
    this.items = const [],
    this.error,
  });

  final bool loading;
  final String scope; // upcoming | past
  final String? vibhagType; // null = all vibhags
  final List<AppEvent> items;
  final String? error;

  EventsState copyWith({
    bool? loading,
    String? scope,
    String? vibhagType,
    bool clearVibhag = false,
    List<AppEvent>? items,
    String? error,
  }) =>
      EventsState(
        loading: loading ?? this.loading,
        scope: scope ?? this.scope,
        vibhagType: clearVibhag ? null : (vibhagType ?? this.vibhagType),
        items: items ?? this.items,
        error: error,
      );
}

class EventsNotifier extends StateNotifier<EventsState> {
  EventsNotifier() : super(const EventsState());

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final items = await EventService.instance
          .list(scope: state.scope, vibhagType: state.vibhagType);
      state = state.copyWith(loading: false, items: items);
    } on AuthException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    }
  }

  Future<void> setScope(String scope) async {
    if (scope == state.scope) return;
    state = state.copyWith(scope: scope);
    await load();
  }

  Future<void> setVibhag(String? type) async {
    if (type == state.vibhagType) return;
    state = type == null
        ? state.copyWith(clearVibhag: true)
        : state.copyWith(vibhagType: type);
    await load();
  }
}

final eventsProvider =
    StateNotifierProvider<EventsNotifier, EventsState>((ref) => EventsNotifier());

// ---- Event detail ----------------------------------------------------------

class EventDetailState {
  const EventDetailState({this.loading = true, this.detail, this.error});
  final bool loading;
  final EventDetail? detail;
  final String? error;
}

class EventDetailNotifier extends StateNotifier<EventDetailState> {
  EventDetailNotifier(this.eventId) : super(const EventDetailState()) {
    load();
  }

  final int eventId;

  Future<void> load() async {
    state = EventDetailState(loading: true, detail: state.detail);
    try {
      final detail = await EventService.instance.detail(eventId);
      state = EventDetailState(loading: false, detail: detail);
    } on AuthException catch (e) {
      state = EventDetailState(loading: false, detail: state.detail, error: e.message);
    }
  }
}

final eventDetailProvider = StateNotifierProvider.family<EventDetailNotifier,
    EventDetailState, int>((ref, eventId) => EventDetailNotifier(eventId));
