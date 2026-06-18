import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/profile_service.dart';
import '../../../core/theme/app_colors.dart';

/// Circular photo picker: tap → camera/gallery sheet → upload → shows photo.
class PhotoPickerField extends StatefulWidget {
  const PhotoPickerField({
    super.key,
    required this.type, // member | spouse | child
    this.initialUrl,
    this.onUploaded,
    this.size = 96,
  });

  final String type;
  final String? initialUrl;
  final ValueChanged<String>? onUploaded;
  final double size;

  @override
  State<PhotoPickerField> createState() => _PhotoPickerFieldState();
}

class _PhotoPickerFieldState extends State<PhotoPickerField> {
  String? _url;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _url = widget.initialUrl;
  }

  Future<void> _pick() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text('Camera', style: GoogleFonts.plusJakartaSans()),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('Gallery', style: GoogleFonts.plusJakartaSans()),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker()
        .pickImage(source: source, maxWidth: 1600, imageQuality: 90);
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final url =
          await ProfileService.instance.uploadPhoto(picked.path, type: widget.type);
      setState(() {
        _url = url;
        _uploading = false;
      });
      widget.onUploaded?.call(url);
    } catch (e) {
      setState(() => _uploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo upload failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _uploading ? null : _pick,
        child: Stack(
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight,
                border: Border.all(color: AppColors.border, width: 2),
                image: _url != null
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                            ProfileService.resolvePhotoUrl(_url!)),
                      )
                    : null,
              ),
              child: _uploading
                  ? const Center(
                      child: SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5)))
                  : _url == null
                      ? const Icon(Icons.add_a_photo_outlined,
                          color: AppColors.primary, size: 28)
                      : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(Icons.edit, size: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
