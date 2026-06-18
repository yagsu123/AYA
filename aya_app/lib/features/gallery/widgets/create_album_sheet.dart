import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/auth_service.dart' show AuthException;
import '../../../core/services/gallery_service.dart';
import '../../../core/theme/app_colors.dart';

/// Create a photo album. Returns `true` when saved.
class CreateAlbumSheet extends StatefulWidget {
  const CreateAlbumSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => const CreateAlbumSheet(),
    );
  }

  @override
  State<CreateAlbumSheet> createState() => _CreateAlbumSheetState();
}

class _CreateAlbumSheetState extends State<CreateAlbumSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  int _year = DateTime.now().year;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await GalleryService.instance.createAlbum(
        title: _title.text.trim(),
        description: _description.text.trim(),
        year: _year,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('New album',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _label('Album title'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.words,
              decoration: _input('e.g. Paryushan 2026'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required.' : null,
            ),
            const SizedBox(height: 16),
            _label('Description (optional)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _description,
              maxLines: 2,
              decoration: _input('A short note about this album'),
            ),
            const SizedBox(height: 16),
            _label('Year'),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              value: _year,
              decoration: _input(''),
              items: [
                for (var y = DateTime.now().year; y >= DateTime.now().year - 20; y--)
                  DropdownMenuItem(value: y, child: Text('$y')),
              ],
              onChanged: (v) => setState(() => _year = v ?? _year),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text('Create album',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.plusJakartaSans(
          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted));

  InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );
}
