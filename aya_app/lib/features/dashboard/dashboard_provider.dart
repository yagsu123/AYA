import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart' show AuthException;
import '../../core/services/dashboard_service.dart';

class DashboardState {
  const DashboardState({this.loading = false, this.data, this.error});
  final bool loading;
  final DashboardData? data;
  final String? error;
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState());

  Future<void> load() async {
    state = DashboardState(loading: true, data: state.data);
    try {
      final data = await DashboardService.instance.fetch();
      state = DashboardState(data: data);
    } on AuthException catch (e) {
      state = DashboardState(data: state.data, error: e.message);
    }
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
        (ref) => DashboardNotifier());
