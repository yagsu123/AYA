import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart' show AuthException;
import '../../core/services/gallery_service.dart';

class GalleryState {
  const GalleryState({this.loading = true, this.albums = const [], this.error});
  final bool loading;
  final List<Album> albums;
  final String? error;
}

class GalleryNotifier extends StateNotifier<GalleryState> {
  GalleryNotifier() : super(const GalleryState()) {
    load();
  }

  Future<void> load() async {
    state = GalleryState(loading: true, albums: state.albums);
    try {
      final albums = await GalleryService.instance.albums();
      state = GalleryState(loading: false, albums: albums);
    } on AuthException catch (e) {
      state = GalleryState(loading: false, albums: state.albums, error: e.message);
    }
  }
}

final galleryProvider =
    StateNotifierProvider<GalleryNotifier, GalleryState>((ref) => GalleryNotifier());

// ---- Album detail ----------------------------------------------------------

class AlbumDetailState {
  const AlbumDetailState({this.loading = true, this.detail, this.error});
  final bool loading;
  final AlbumDetail? detail;
  final String? error;
}

class AlbumDetailNotifier extends StateNotifier<AlbumDetailState> {
  AlbumDetailNotifier(this.albumId) : super(const AlbumDetailState()) {
    load();
  }

  final int albumId;

  Future<void> load() async {
    state = AlbumDetailState(loading: true, detail: state.detail);
    try {
      final detail = await GalleryService.instance.album(albumId);
      state = AlbumDetailState(loading: false, detail: detail);
    } on AuthException catch (e) {
      state = AlbumDetailState(loading: false, detail: state.detail, error: e.message);
    }
  }
}

final albumDetailProvider = StateNotifierProvider.family<AlbumDetailNotifier,
    AlbumDetailState, int>((ref, albumId) => AlbumDetailNotifier(albumId));
