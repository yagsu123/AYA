import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart' show AuthException;
import '../../core/services/vibhag_service.dart';

class VibhagsState {
  const VibhagsState({this.loading = true, this.data, this.error});
  final bool loading;
  final VibhagList? data;
  final String? error;
}

class VibhagsNotifier extends StateNotifier<VibhagsState> {
  VibhagsNotifier() : super(const VibhagsState()) {
    load();
  }

  Future<void> load() async {
    state = VibhagsState(loading: true, data: state.data);
    try {
      final data = await VibhagService.instance.list();
      state = VibhagsState(loading: false, data: data);
    } on AuthException catch (e) {
      state = VibhagsState(loading: false, data: state.data, error: e.message);
    }
  }
}

final vibhagsProvider =
    StateNotifierProvider<VibhagsNotifier, VibhagsState>((ref) => VibhagsNotifier());

// ---- Vibhag detail ---------------------------------------------------------

class VibhagDetailState {
  const VibhagDetailState({this.loading = true, this.detail, this.error});
  final bool loading;
  final VibhagDetail? detail;
  final String? error;
}

class VibhagDetailNotifier extends StateNotifier<VibhagDetailState> {
  VibhagDetailNotifier(this.type) : super(const VibhagDetailState()) {
    load();
  }

  final String type;

  Future<void> load() async {
    state = VibhagDetailState(loading: true, detail: state.detail);
    try {
      final detail = await VibhagService.instance.detail(type);
      state = VibhagDetailState(loading: false, detail: detail);
    } on AuthException catch (e) {
      state = VibhagDetailState(loading: false, detail: state.detail, error: e.message);
    }
  }
}

final vibhagDetailProvider = StateNotifierProvider.family<VibhagDetailNotifier,
    VibhagDetailState, String>((ref, type) => VibhagDetailNotifier(type));
