import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/contact_actions.dart';
import '../../auth/auth_provider.dart';

const _privacyPolicyUrl = 'https://aradhanayouth.org/privacy';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = 'v${info.version} (${info.buildNumber})');
    } catch (_) {
      if (mounted) setState(() => _version = '');
    }
  }

  Future<void> _logout() async {
    final confirmed = await showPlatformDialog<bool>(
      context: context,
      builder: (ctx) => PlatformAlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again.'),
        actions: [
          PlatformDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          PlatformDialogAction(
            cupertino: (_, __) => CupertinoDialogActionData(isDestructiveAction: true),
            child: const Text('Sign out'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(authProvider.notifier).logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text('Settings',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _sectionLabel('PREFERENCES'),
          _card([
            _rowCustom(
              Icons.translate_rounded,
              'Language',
              trailing: _langToggle(locale),
            ),
          ]),
          const SizedBox(height: 20),
          _sectionLabel('ABOUT'),
          _card([
            _row(Icons.info_outline_rounded, 'App version',
                trailingText: _version.isEmpty ? '—' : _version),
            _divider(),
            _row(Icons.privacy_tip_outlined, 'Privacy Policy',
                onTap: () => _launch(_privacyPolicyUrl)),
            _divider(),
            _row(Icons.support_agent_rounded, 'Contact administrator',
                subtitle: '${AppConstants.adminName} · ${AppConstants.adminMobile}',
                onTap: () => ContactActions.whatsapp(AppConstants.adminMobile)),
          ]),
          const SizedBox(height: 20),
          _sectionLabel('ACCOUNT'),
          _card([
            _row(Icons.logout_rounded, 'Sign out',
                color: AppColors.danger, onTap: _logout),
          ]),
        ],
      ),
    );
  }

  Future<void> _launch(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not open the link.')));
      }
    }
  }

  Widget _langToggle(String locale) {
    Widget pill(String label, String code) {
      final selected = locale == code;
      return GestureDetector(
        onTap: () {
          if (!selected) ref.read(languageProvider.notifier).toggle();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textMuted)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [pill('EN', 'en'), pill('हिंदी', 'hi')]),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
        child: Text(text,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: AppColors.textMuted)),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: children),
      );

  Widget _divider() =>
      const Divider(height: 1, indent: 52, color: AppColors.border);

  Widget _row(IconData icon, String title,
      {String? subtitle,
      String? trailingText,
      Color? color,
      VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 22, color: color ?? AppColors.primary),
      title: Text(title,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.textPrimary)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: AppColors.textMuted)),
      trailing: trailingText == null
          ? (onTap != null ? const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted) : null)
          : Text(trailingText,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.textMuted)),
    );
  }

  Widget _rowCustom(IconData icon, String title, {required Widget trailing}) {
    return ListTile(
      leading: Icon(icon, size: 22, color: AppColors.primary),
      title: Text(title,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      trailing: trailing,
    );
  }
}
