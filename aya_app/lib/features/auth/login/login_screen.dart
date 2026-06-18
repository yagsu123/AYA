import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/aya_logo.dart';
import '../../../core/widgets/contact_action_row.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _rememberMe = false;
  bool _obscure = true;

  String? _mobileError;
  String? _passwordError;
  String? _bannerError;

  @override
  void initState() {
    super.initState();
    _prefillSavedMobile();
  }

  Future<void> _prefillSavedMobile() async {
    final saved = await StorageService.instance.savedMobile;
    if (saved != null && mounted) {
      setState(() {
        _mobileCtrl.text = saved;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _mobileError = null;
      _passwordError = null;
      _bannerError = null;
    });
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(authProvider.notifier).login(
          _mobileCtrl.text.trim(),
          _passwordCtrl.text,
          rememberMe: _rememberMe,
        );
    if (!mounted) return;

    if (ok) {
      final role = ref.read(authProvider).member?.role;
      context.go(role == 'president' || role == 'secretary' ? '/admin' : '/dashboard');
      return;
    }

    final auth = ref.read(authProvider);
    switch (auth.errorCode) {
      case 'MOBILE_NOT_FOUND':
        setState(() => _mobileError = 'Mobile number not found');
      case 'INCORRECT_PASSWORD':
        setState(() => _passwordError = 'Incorrect password');
      case 'ACCOUNT_INACTIVE':
        setState(() => _bannerError = 'Account is inactive. Contact administrator.');
      case 'NETWORK':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection failed. Please try again.')),
        );
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage ?? 'Something went wrong.')),
        );
    }
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    String? errorText,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        labelText: label,
        errorText: errorText,
        counterText: '',
        prefixIcon: Icon(icon, size: 20, color: AppColors.textMuted),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).status == AuthStatus.loading;
    final size = MediaQuery.of(context).size;
    final headerHeight = (size.height * 0.34).clamp(240.0, 320.0);

    return PlatformScaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            child: Stack(
              children: [
                // ===== Blue gradient header =====
                Container(
                  height: headerHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(36)),
                  ),
                  child: Stack(
                    children: [
                      // Decorative rings + orbs
                      Positioned(
                        top: -40, right: -30,
                        child: _ring(140, Colors.white.withOpacity(0.08)),
                      ),
                      Positioned(
                        top: 60, right: 40,
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.amber.withOpacity(0.3),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 30, left: -25,
                        child: _ring(100, Colors.white.withOpacity(0.06)),
                      ),
                      // Logo + name
                      SafeArea(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const AyaLogo(size: 84),
                              const SizedBox(height: 14),
                              Text('Aradhana Youth Association',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                              const SizedBox(height: 4),
                              Text('Connecting Members Digitally',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.75))),
                              SizedBox(height: headerHeight * 0.14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== Overlapping white card =====
                Positioned(
                  top: headerHeight - 44,
                  left: 20,
                  right: 20,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 440),
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Welcome back 🙏',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text('Sign in to continue',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13, color: AppColors.textMuted)),
                          const SizedBox(height: 22),

                          if (_bannerError != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.danger.withOpacity(0.35)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppColors.danger, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(_bannerError!,
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.danger)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          TextFormField(
                            controller: _mobileCtrl,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14, fontWeight: FontWeight.w600),
                            decoration: _decoration(
                              label: 'Mobile number',
                              icon: Icons.phone_outlined,
                              errorText: _mobileError,
                            ),
                            validator: Validators.mobile,
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14, fontWeight: FontWeight.w600),
                            decoration: _decoration(
                              label: 'Password',
                              icon: Icons.lock_outline,
                              errorText: _passwordError,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: Validators.password,
                            onFieldSubmitted: (_) => isLoading ? null : _submit(),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              PlatformSwitch(
                                value: _rememberMe,
                                activeColor: AppColors.primary,
                                onChanged: (v) async {
                                  setState(() => _rememberMe = v);
                                  if (!v) {
                                    await StorageService.instance
                                        .clearSavedMobile();
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              Text('Remember me',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Gradient sign-in button
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22, height: 22,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white))
                                    : Text('Sign in',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          Center(
                            child: InkWell(
                              onTap: () => _showAdminContactSheet(context),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Trouble signing in? ',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        color: AppColors.textMuted),
                                    children: [
                                      TextSpan(
                                        text: 'Contact administrator',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAdminContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight,
                ),
                child: const Icon(Icons.support_agent,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 12),
              Text(AppConstants.adminName,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('+91 ${AppConstants.adminMobile}',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, color: AppColors.textMuted)),
              const SizedBox(height: 8),
              Text(
                'Reach out for new accounts, password resets, or reactivation.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: AppColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 20),
              const ContactActionRow(
                name: AppConstants.adminName,
                mobile: AppConstants.adminMobile,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _ring(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 14),
        ),
      );
}
