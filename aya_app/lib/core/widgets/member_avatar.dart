import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/profile_service.dart';
import '../theme/app_colors.dart';

/// Circular member/person avatar: shows the photo when available, otherwise
/// coloured initials. Reused by sponsor lists, vibhag heads and pickers so the
/// avatar logic lives in exactly one place.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 22,
    this.color = AppColors.primary,
  });

  final String name;
  final String? photoUrl;
  final double radius;
  final Color color;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return letters.isEmpty ? '?' : letters;
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withOpacity(0.15),
      backgroundImage: hasPhoto
          ? CachedNetworkImageProvider(ProfileService.resolvePhotoUrl(photoUrl!))
          : null,
      child: hasPhoto
          ? null
          : Text(
              _initials,
              style: GoogleFonts.plusJakartaSans(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
    );
  }
}
