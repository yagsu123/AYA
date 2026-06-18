import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/auth_service.dart' show AuthException;
import '../../../core/services/event_service.dart';
import '../../../core/theme/app_colors.dart';

/// Add a labarthi (beneficiary) record to an event: name, optional private
/// contribution amount and note. Returns `true` when saved.
class LabarthiFormSheet extends StatefulWidget {
  const LabarthiFormSheet({super.key, required this.eventId});

  final int eventId;

  static Future<bool?> show(BuildContext context, {required int eventId}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => LabarthiFormSheet(eventId: eventId),
    );
  }

  @override
  State<LabarthiFormSheet> createState() => _LabarthiFormSheetState();
}

class _LabarthiFormSheetState extends State<LabarthiFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await EventService.instance.addLabarthi(
        widget.eventId,
        name: _name.text.trim(),
        amount: _amount.text.trim().isEmpty
            ? null
            : double.tryParse(_amount.text.trim()),
        note: _note.text.trim(),
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
            Text('Add labarthi',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _label('Labarthi name'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: _input('e.g. Shah Family'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required.' : null,
            ),
            const SizedBox(height: 16),
            _label('Contribution amount (optional)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              decoration: _input('e.g. 2100', prefix: '₹ '),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 13, color: AppColors.textMuted),
                const SizedBox(width: 5),
                Expanded(
                  child: Text('Amount stays private — visible only to admins.',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5, color: AppColors.textMuted)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _label('Note (optional)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _note,
              maxLines: 2,
              decoration: _input('Anything to record internally'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text('Add labarthi',
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

  InputDecoration _input(String hint, {String? prefix}) => InputDecoration(
        hintText: hint,
        prefixText: prefix,
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
          borderSide: const BorderSide(color: AppColors.amber, width: 1.5),
        ),
      );
}
