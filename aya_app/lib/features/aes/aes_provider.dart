import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart' show AuthException;
import '../../core/services/aes_service.dart';

class AesState {
  const AesState({this.loading = true, this.data, this.error});
  final bool loading;
  final AesData? data;
  final String? error;
}

class AesNotifier extends StateNotifier<AesState> {
  AesNotifier() : super(const AesState()) {
    load();
  }

  Future<void> load() async {
    state = AesState(loading: true, data: state.data);
    try {
      final data = await AesService.instance.get();
      state = AesState(loading: false, data: data);
    } on AuthException catch (e) {
      state = AesState(loading: false, data: state.data, error: e.message);
    }
  }
}

final aesProvider =
    StateNotifierProvider<AesNotifier, AesState>((ref) => AesNotifier());
