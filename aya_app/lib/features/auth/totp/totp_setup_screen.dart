import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../auth_provider.dart';

/// Data passed from the login screen into the first-login authenticator setup.
class TotpSetupArgs {
  const TotpSetupArgs({
    required this.mobile,
    required this.password,
    required this.otpauthUrl,
    required this.secret,
    required this.rememberMe,
  });

  final String mobile;
  final String password;
  final String otpauthUrl;
  final String secret;
  final bool rememberMe;
}

/// First sign-in screen: the member scans the QR (or enters the key) into an
/// authenticator app, then confirms a 6-digit code to finish enrolment.
class TotpSetupScreen extends ConsumerStatefulWidget {
  const TotpSetupScreen({super.key, required this.args});

  final TotpSetupArgs args;

  @override
  ConsumerState<TotpSetupScreen> createState() => _TotpSetupScreenState();
}

class _TotpSetupScreenState extends ConsumerState<TotpSetupScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Enter the 6-digit code from your authenticator app.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = await ref.read(authProvider.notifier).completeTotpSetup(
          mobile: widget.args.mobile,
          password: widget.args.password,
          token: code,
          rememberMe: widget.args.rememberMe,
        );
    if (!mounted) return;

    if (ok) {
      final role = ref.read(authProvider).member?.role;
      context.go(role == 'president' || role == 'secretary' ? '/admin' : '/dashboard');
      return;
    }

    setState(() {
      _loading = false;
      _error = ref.read(authProvider).errorMessage ?? 'Verification failed. Please try again.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text('Secure your account',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('One-time setup',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text(
                'For your security, set up an authenticator app. Install '
                'Google Authenticator or Authy, then scan the code below.',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, height: 1.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),

              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: QrImageView(
                    data: widget.args.otpauthUrl,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Text("Can't scan? Enter this key manually:",
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5, color: AppColors.textMuted)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        widget.args.secret,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: AppColors.primaryDark),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18, color: AppColors.primary),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.args.secret));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Key copied')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Enter the 6-digit code',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 8),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                  errorText: _error,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
                  ),
                ),
                onSubmitted: (_) => _loading ? null : _verify(),
              ),
              const SizedBox(height: 18),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verify,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : Text('Verify & continue',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
