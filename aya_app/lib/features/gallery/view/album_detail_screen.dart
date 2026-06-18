import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/auth_service.dart' show AuthException;
import '../../../core/services/gallery_service.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../gallery_provider.dart';

class AlbumDetailScreen extends ConsumerStatefulWidget {
  const AlbumDetailScreen({super.key, required this.albumId});

  final int albumId;

  @override
  ConsumerState<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends ConsumerState<AlbumDetailScreen> {
  bool _uploading = false;

  void _reload() => ref.read(albumDetailProvider(widget.albumId).notifier).load();

  Future<void> _addPhoto() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 2000, imageQuality: 90);
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      await GalleryService.instance.uploadPhoto(widget.albumId, picked.path);
      _reload();
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _deleteAlbum(Album album) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete album'),
        content: Text('Delete "${album.title}" and all its photos?'),
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
    if (ok != true) return;
    try {
      await GalleryService.instance.deleteAlbum(album.id);
      if (mounted) context.pop();
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _openViewer(AlbumDetail detail, int index) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _PhotoViewer(
        photos: detail.photos,
        initialIndex: index,
        canManage: detail.canManage,
      ),
    ));
    _reload(); // a photo may have been deleted in the viewer
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(albumDetailProvider(widget.albumId));
    final detail = state.detail;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text(detail?.album.title ?? 'Album',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        actions: [
          if (detail != null && detail.canManage)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
              tooltip: 'Delete album',
              onPressed: () => _deleteAlbum(detail.album),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _uploading ? null : _addPhoto,
        icon: _uploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.add_a_photo_outlined, color: Colors.white),
        label: Text(_uploading ? 'Uploading…' : 'Add photo',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: state.loading && detail == null
          ? const Center(child: CircularProgressIndicator())
          : detail == null
              ? Center(
                  child: Text(state.error ?? 'Album not found.',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted)))
              : detail.photos.isEmpty
                  ? _empty()
                  : RefreshIndicator(
                      onRefresh: () async => _reload(),
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                        itemCount: detail.photos.length,
                        itemBuilder: (_, i) => GestureDetector(
                          onTap: () => _openViewer(detail, i),
                          child: Hero(
                            tag: 'photo_${detail.photos[i].id}',
                            child: CachedNetworkImage(
                              imageUrl:
                                  ProfileService.resolvePhotoUrl(detail.photos[i].imageUrl),
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: AppColors.primaryLight),
                              errorWidget: (_, __, ___) =>
                                  const ColoredBox(color: AppColors.primaryLight),
                            ),
                          ),
                        ),
                      ),
                    ),
    );
  }

  Widget _empty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_a_photo_outlined, size: 46, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('No photos yet. Tap "Add photo".',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5, color: AppColors.textMuted)),
          ],
        ),
      );
}

/// Full-screen, swipeable, zoomable photo viewer.
class _PhotoViewer extends StatefulWidget {
  const _PhotoViewer({
    required this.photos,
    required this.initialIndex,
    required this.canManage,
  });

  final List<Photo> photos;
  final int initialIndex;
  final bool canManage;

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);
  late List<Photo> _photos = [...widget.photos];
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete photo'),
        content: const Text('Remove this photo from the album?'),
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
    if (ok != true) return;
    final photo = _photos[_index];
    try {
      await GalleryService.instance.deletePhoto(photo.id);
      if (!mounted) return;
      setState(() => _photos.removeAt(_index));
      if (_photos.isEmpty && mounted) {
        Navigator.of(context).pop();
      } else if (_index >= _photos.length) {
        setState(() => _index = _photos.length - 1);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('${_index + 1} / ${_photos.length}',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white)),
        actions: [
          if (widget.canManage)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _delete,
            ),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (i) => setState(() => _index = i),
        itemCount: _photos.length,
        itemBuilder: (_, i) {
          final p = _photos[i];
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Hero(
                      tag: 'photo_${p.id}',
                      child: CachedNetworkImage(
                        imageUrl: ProfileService.resolvePhotoUrl(p.imageUrl),
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(color: Colors.white24)),
                      ),
                    ),
                  ),
                ),
                if (p.caption != null && p.caption!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(p.caption!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, color: Colors.white70)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
