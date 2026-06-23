import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/auth_service.dart' show AuthException;
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/contact_actions.dart';
import '../../../core/utils/validators.dart';
import 'admin_provider.dart';

/// Bottom sheet: enter mobile → POST /api/admin/members →
/// show one-time temp password dialog with copy button.
class AddMemberSheet extends ConsumerStatefulWidget {
  const AddMemberSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => const AddMemberSheet(),
      );

  @override
  ConsumerState<AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends ConsumerState<AddMemberSheet> {
  final _formKey = GlobalKey<FormState>();
  final _mobileCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _mobileCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final result =
          await ref.read(adminProvider.notifier).addMember(_mobileCtrl.text.trim());
      if (!mounted) return;
      // Capture a context that survives the sheet closing.
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      Navigator.of(context).pop(); // close sheet
      _showTempPasswordDialog(rootContext, result.mobile, result.tempPassword);
    } on AuthException catch (e) {
      setState(() {
        _loading = false;
        _error = e.code == 'MEMBER_LIMIT_REACHED'
            ? 'Maximum member limit reached.'
            : e.message;
      });
    }
  }

  void _showTempPasswordDialog(BuildContext rootContext, String mobile, String tempPassword) {
    showDialog(
      context: rootContext,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Member added',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share this password with $mobile so they can sign in. '
                'It is the common member password.',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: AppColors.textMuted, height: 1.5)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tempPassword,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 18, fontWeight: FontWeight.w800,
                          letterSpacing: 2, color: AppColors.primaryDark)),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20, color: AppColors.primary),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: tempPassword));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Password copied')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () =>
                ContactActions.whatsapp(mobile, message: _credentialsMessage(mobile, tempPassword)),
            icon: const Icon(Icons.chat, size: 18, color: AppColors.primary),
            label: Text('Send on WhatsApp',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Done',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  /// Pre-filled WhatsApp message a member receives with their login details.
  String _credentialsMessage(String mobile, String tempPassword) =>
      '🙏 Welcome to AYA — Sree Aradhana Youth Association!\n\n'
      'Your login details:\n'
      'Mobile: $mobile\n'
      'Password: $tempPassword\n\n'
      'Open the AYA app and sign in with these. '
      'On your first sign-in you will set up a quick authenticator code for security.';

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add member',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('They will sign in with the common member password.',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _mobileCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Mobile number',
                counterText: '',
                errorText: _error,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              ),
              validator: Validators.mobile,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Add member'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
