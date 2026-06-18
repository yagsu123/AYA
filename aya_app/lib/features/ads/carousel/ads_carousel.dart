import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/dashboard_service.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/app_colors.dart';

/// Auto-scrolling ad carousel (3 s interval) with dot indicators.
class AdsCarousel extends StatefulWidget {
  const AdsCarousel({super.key, required this.ads});

  final List<Ad> ads;

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  final _pageCtrl = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    if (widget.ads.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted || !_pageCtrl.hasClients) return;
        final next = (_page + 1) % widget.ads.length;
        _pageCtrl.animateToPage(next,
            duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: widget.ads.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) {
              final ad = widget.ads[i];
              return GestureDetector(
                onTap: ad.linkUrl == null
                    ? null
                    : () => launchUrl(Uri.parse(ad.linkUrl!),
                        mode: LaunchMode.externalApplication),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.border,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: ProfileService.resolvePhotoUrl(ad.imageUrl),
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.primaryLight,
                          child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image_outlined,
                                color: AppColors.textMuted)),
                      ),
                      if (ad.title != null && ad.title!.isNotEmpty)
                        Positioned(
                          left: 0, right: 0, bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(14, 20, 14, 10),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black87],
                              ),
                            ),
                            child: Text(ad.title!,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < widget.ads.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
