import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/gallery_service.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../gallery_provider.dart';
import '../widgets/create_album_sheet.dart';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final saved = await CreateAlbumSheet.show(context);
    if (saved == true) ref.read(galleryProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(galleryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text('Gallery',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
        label: Text('New album',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: state.loading && state.albums.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.albums.isEmpty
              ? Center(
                  child: Text(state.error!,
                      style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted)))
              : state.albums.isEmpty
                  ? _empty()
                  : RefreshIndicator(
                      onRefresh: () => ref.read(galleryProvider.notifier).load(),
                      child: _groupedByYear(context, ref, state.albums),
                    ),
    );
  }

  Widget _groupedByYear(BuildContext context, WidgetRef ref, List<Album> albums) {
    // Albums arrive already sorted by year (newest first).
    final years = <int>[];
    final byYear = <int, List<Album>>{};
    for (final a in albums) {
      if (!byYear.containsKey(a.year)) years.add(a.year);
      byYear.putIfAbsent(a.year, () => []).add(a);
    }
    final pad = Responsive.padding(context);
    final cols = Responsive.isMobile(context) ? 2 : 3;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(pad, 8, pad, 90),
      itemCount: years.length,
      itemBuilder: (_, i) {
        final year = years[i];
        final list = byYear[year]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 14, 0, 10),
              child: Row(
                children: [
                  Text('$year',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const SizedBox(width: 8),
                  Text('${list.length} album${list.length == 1 ? '' : 's'}',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: list.length,
              itemBuilder: (_, j) => _AlbumCard(
                album: list[j],
                onTap: () => context
                    .push('/gallery/${list[j].id}')
                    .then((_) => ref.read(galleryProvider.notifier).load()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _empty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_library_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('No albums yet. Tap "New album" to start.',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5, color: AppColors.textMuted)),
          ],
        ),
      );
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.album, required this.onTap});
  final Album album;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasCover = album.coverUrl != null && album.coverUrl!.isNotEmpty;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasCover)
                    CachedNetworkImage(
                      imageUrl: ProfileService.resolvePhotoUrl(album.coverUrl!),
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: AppColors.primaryLight),
                      errorWidget: (_, __, ___) =>
                          const ColoredBox(color: AppColors.primaryLight),
                    )
                  else
                    Container(
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.photo_library_rounded,
                          size: 36, color: AppColors.primary),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo_outlined, size: 12, color: Colors.white),
                          const SizedBox(width: 3),
                          Text('${album.photoCount}',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Text(album.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}
