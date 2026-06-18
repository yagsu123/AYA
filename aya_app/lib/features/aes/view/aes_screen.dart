import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/aes_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/contact_actions.dart';
import '../aes_provider.dart';
import '../widgets/aes_edit_sheet.dart';

class AesScreen extends ConsumerWidget {
  const AesScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, AesContent content) async {
    final saved = await AesEditSheet.show(context, content);
    if (saved == true) ref.read(aesProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aesProvider);
    final data = state.data;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text('AES',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        actions: [
          if (data != null && data.isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              tooltip: 'Edit',
              onPressed: () => _edit(context, ref, data.content),
            ),
        ],
      ),
      body: state.loading && data == null
          ? const Center(child: CircularProgressIndicator())
          : data == null
              ? Center(
                  child: Text(state.error ?? 'Could not load AES.',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted)))
              : RefreshIndicator(
                  onRefresh: () => ref.read(aesProvider.notifier).load(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      _banner(),
                      const SizedBox(height: 16),
                      _infoCard('What is AES?', data.content.whatIsAes,
                          Icons.school_rounded, AppColors.primary),
                      const SizedBox(height: 12),
                      _infoCard('History', data.content.history,
                          Icons.auto_stories_rounded, AppColors.purple),
                      const SizedBox(height: 12),
                      _infoCard('Objectives', data.content.objectives,
                          Icons.flag_rounded, AppColors.amber),
                      const SizedBox(height: 16),
                      _donationCard(context, data.content),
                      const SizedBox(height: 16),
                      _progressCard(data.content),
                    ],
                  ),
                ),
    );
  }

  Widget _banner() => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.success, Color(0xFF0D9488)],
            ),
          ),
          child: Stack(
            children: [
              // Decorative concentric rings (quiet, rangoli-inspired).
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.12), width: 14),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.account_balance_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 14),
                  Text('Aradhana Education Society',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Education · Welfare · Community',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5, color: Colors.white.withOpacity(0.9))),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _infoCard(String title, String? body, IconData icon, Color accent) {
    final text = (body == null || body.trim().isEmpty) ? 'Not added yet.' : body;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(text,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5, height: 1.6, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _donationCard(BuildContext context, AesContent content) {
    final contact = content.donationContact;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amberLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Support AES',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.amberDark)),
          const SizedBox(height: 4),
          Text('Contribute towards education and welfare.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5, color: AppColors.amberDark.withOpacity(0.8))),
          const SizedBox(height: 14),
          if (contact != null && contact.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: _btn('WhatsApp', Icons.chat_rounded, const Color(0xFF25D366),
                      () => ContactActions.whatsapp(contact,
                          message: 'I would like to contribute to Aradhana Education Society.')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _btn('Call', Icons.call_rounded, AppColors.success,
                      () => ContactActions.call(contact)),
                ),
              ],
            )
          else
            Text('Donation contact not set.',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5, color: AppColors.amberDark.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _btn(String label, IconData icon, Color color, VoidCallback onTap) => SizedBox(
        height: 42,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onTap,
          icon: Icon(icon, size: 18, color: Colors.white),
          label: Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      );

  Widget _progressCard(AesContent content) {
    if (content.progressTarget <= 0) return const SizedBox.shrink();
    final pct = content.progressPct;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fund progress',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Text('₹${_money(content.progressCurrent)} raised of ₹${_money(content.progressTarget)} goal',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: AppColors.primaryLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Text('${(pct * 100).round()}% of goal',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  static String _money(double v) {
    final s = v.toStringAsFixed(0);
    // Indian grouping (e.g. 1,00,000).
    final buf = StringBuffer();
    final digits = s.split('');
    final n = digits.length;
    for (var i = 0; i < n; i++) {
      buf.write(digits[i]);
      final fromEnd = n - 1 - i;
      if (fromEnd > 0 && (fromEnd == 3 || (fromEnd > 3 && (fromEnd - 3) % 2 == 0))) {
        buf.write(',');
      }
    }
    return buf.toString();
  }
}
