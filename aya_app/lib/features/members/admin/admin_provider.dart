import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/services/auth_service.dart' show AuthException;

class AdminState {
  const AdminState({
    this.loading = false,
    this.stats,
    this.members = const [],
    this.error,
  });

  final bool loading;
  final AdminStats? stats;
  final List<AdminMember> members;
  final String? error;

  AdminState copyWith({
    bool? loading,
    AdminStats? stats,
    List<AdminMember>? members,
    String? error,
  }) =>
      AdminState(
        loading: loading ?? this.loading,
        stats: stats ?? this.stats,
        members: members ?? this.members,
        error: error,
      );
}

class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier() : super(const AdminState());

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final results = await Future.wait([
        AdminService.instance.stats(),
        AdminService.instance.members(),
      ]);
      state = AdminState(
        loading: false,
        stats: results[0] as AdminStats,
        members: results[1] as List<AdminMember>,
      );
    } on AuthException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    }
  }

  /// Returns the temp password on success, throws AuthException on failure.
  Future<NewMemberResult> addMember(String mobile) async {
    final result = await AdminService.instance.addMember(mobile);
    await load(); // refresh list + stats
    return result;
  }

  Future<void> deleteMember(int id) async {
    await AdminService.instance.deleteMember(id);
    await load(); // refresh list + stats
  }

  Future<void> setStatus(int id, String status) async {
    // Optimistic update, rolled back on failure.
    final before = state.members;
    state = state.copyWith(
      members: [
        for (final m in before) m.id == id ? m.copyWith(status: status) : m,
      ],
    );
    try {
      await AdminService.instance.setStatus(id, status);
      // Refresh stats quietly (active/inactive counts changed).
      final stats = await AdminService.instance.stats();
      state = state.copyWith(stats: stats);
    } on AuthException catch (e) {
      state = state.copyWith(members: before, error: e.message);
      rethrow;
    }
  }
}

final adminProvider =
    StateNotifierProvider<AdminNotifier, AdminState>((ref) => AdminNotifier());
