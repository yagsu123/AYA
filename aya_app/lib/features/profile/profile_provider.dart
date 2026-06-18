import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart' show AuthException;
import '../../core/services/profile_service.dart';

class ProfileState {
  const ProfileState({this.loading = false, this.bundle, this.error});
  final bool loading;
  final ProfileBundle? bundle;
  final String? error;

  ProfileState copyWith({bool? loading, ProfileBundle? bundle, String? error}) =>
      ProfileState(
        loading: loading ?? this.loading,
        bundle: bundle ?? this.bundle,
        error: error,
      );
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState());

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final bundle = await ProfileService.instance.me();
      state = ProfileState(bundle: bundle);
    } on AuthException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    }
  }

  Future<void> save(Map<String, dynamic> fields) async {
    await ProfileService.instance.update(fields);
    await load();
  }

  Future<void> addChild({required String name, DateTime? dob, String? contact, String? photoUrl}) async {
    await ProfileService.instance
        .addChild(name: name, dob: dob, contact: contact, photoUrl: photoUrl);
    await load();
  }

  Future<void> deleteChild(int id) async {
    await ProfileService.instance.deleteChild(id);
    await load();
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) => ProfileNotifier());
