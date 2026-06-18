import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/aes_service.dart';
import '../../../core/services/auth_service.dart' show AuthException;
import '../../../core/theme/app_colors.dart';

/// Admin editor for the AES content. Returns `true` when saved.
class AesEditSheet extends StatefulWidget {
  const AesEditSheet({super.key, required this.content});

  final AesContent content;

  static Future<bool?> show(BuildContext context, AesContent content) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => AesEditSheet(content: content),
    );
  }

  @override
  State<AesEditSheet> createState() => _AesEditSheetState();
}

class _AesEditSheetState extends State<AesEditSheet> {
  late final _what = TextEditingController(text: widget.content.whatIsAes ?? '');
  late final _history = TextEditingController(text: widget.content.history ?? '');
  late final _objectives = TextEditingController(text: widget.content.objectives ?? '');
  late final _contact = TextEditingController(text: widget.content.donationContact ?? '');
  late final _current = TextEditingController(
      text: widget.content.progressCurrent == 0
          ? ''
          : widget.content.progressCurrent.toStringAsFixed(0));
  late final _target = TextEditingController(
      text: widget.content.progressTarget == 0
          ? ''
          : widget.content.progressTarget.toStringAsFixed(0));
  bool _saving = false;

  @override
  void dispose() {
    _what.dispose();
    _history.dispose();
    _objectives.dispose();
    _contact.dispose();
    _current.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await AesService.instance.update(
        whatIsAes: _what.text.trim(),
        history: _history.text.trim(),
        objectives: _objectives.text.trim(),
        donationContact: _contact.text.trim(),
        progressCurrent: double.tryParse(_current.text.trim()) ?? 0,
        progressTarget: double.tryParse(_target.text.trim()) ?? 0,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border, borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Edit AES',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _field('What is AES?', _what, lines: 3),
            _field('History', _history, lines: 3),
            _field('Objectives', _objectives, lines: 3),
            _field('Donation contact (10 digits)', _contact,
                keyboard: TextInputType.phone,
                formatters: [FilteringTextInputFormatter.digitsOnly], maxLen: 10),
            Row(
              children: [
                Expanded(
                    child: _field('Raised (₹)', _current,
                        keyboard: TextInputType.number,
                        formatters: [FilteringTextInputFormatter.digitsOnly])),
                const SizedBox(width: 12),
                Expanded(
                    child: _field('Goal (₹)', _target,
                        keyboard: TextInputType.number,
                        formatters: [FilteringTextInputFormatter.digitsOnly])),
              ],
            ),
            const SizedBox(height: 8),
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
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Save',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
      {int lines = 1, TextInputType? keyboard, List<TextInputFormatter>? formatters, int? maxLen}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            maxLines: lines,
            keyboardType: keyboard,
            inputFormatters: formatters,
            maxLength: maxLen,
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            ),
          ),
        ],
      ),
    );
  }
}
