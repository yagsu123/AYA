import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/contact_action_row.dart';
import '../../../core/widgets/role_pending_chip.dart';
import '../profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final bundle = state.bundle;
    final p = bundle?.profile;
    final pad = Responsive.padding(context);
    final name = p?.fullName ?? 'Name not set';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text('MEMBER PROFILE',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14, fontWeight: FontWeight.w800,
                letterSpacing: 1, color: AppColors.textPrimary)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: () => context.push('/profile/complete'),
              icon: const Icon(Icons.edit, size: 14),
              label: const Text('Edit'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
                textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: state.loading || bundle == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(profileProvider.notifier).load(),
              child: ListView(
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 32),
                children: [
                  // ===== Header: centered avatar + name + role + mobile =====
                  Center(
                    child: Container(
                      width: 104,
                      height: 104,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: p?.photoUrl != null
                            ? CachedNetworkImageProvider(
                                ProfileService.resolvePhotoUrl(p!.photoUrl!))
                            : null,
                        child: p?.photoUrl == null
                            ? Text(_initials(name),
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 28, fontWeight: FontWeight.w800,
                                    color: AppColors.primary))
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(name,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 20, fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text((bundle.role ?? 'member').toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11, fontWeight: FontWeight.w700,
                                letterSpacing: 1, color: AppColors.primary)),
                        if (bundle.roleStatus == 'pending') ...[
                          const SizedBox(width: 6),
                          const RolePendingChip(),
                        ],
                      ],
                    ),
                  ),
                  if (bundle.mobile != null) ...[
                    const SizedBox(height: 4),
                    Center(
                      child: Text(bundle.mobile!,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, color: AppColors.textMuted)),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // ===== Contact actions =====
                  ContactActionRow(
                    name: name,
                    mobile: bundle.mobile,
                    email: p?.email,
                  ),
                  const SizedBox(height: 20),

                  // ===== Completion bar (hidden at 100%) =====
                  if ((p?.completePct ?? 0) < 100) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.amberLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Profile completion',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12, fontWeight: FontWeight.w600,
                                      color: AppColors.amberDark)),
                              Text('${p?.completePct ?? 0}%',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13, fontWeight: FontWeight.w800,
                                      color: AppColors.amberDark)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: (p?.completePct ?? 0) / 100,
                              minHeight: 6,
                              backgroundColor: Colors.white,
                              valueColor:
                                  const AlwaysStoppedAnimation(AppColors.amber),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ===== Sections =====
                  _Section(
                    title: 'PERSONAL DETAILS',
                    initiallyExpanded: true,
                    children: [
                      _row('Email Address', p?.email),
                      _row('Date of Birth',
                          p?.dob == null ? null : Formatters.date(p!.dob!)),
                      _row('Anniversary Date',
                          p?.anniversaryDate == null
                              ? null
                              : Formatters.date(p!.anniversaryDate!)),
                      _row('Blood Group', p?.bloodGroup),
                      _row('Native Place', p?.nativePlace),
                    ],
                  ),
                  _Section(
                    title: 'RESIDENTIAL DETAILS',
                    children: [
                      _row('Address', p?.resAddress),
                      _row('Phone', p?.resPhone),
                    ],
                  ),
                  _Section(
                    title: 'OFFICE DETAILS',
                    children: [
                      _row('Address', p?.officeAddress),
                      _row('Phone', p?.officePhone),
                    ],
                  ),
                  _Section(
                    title: 'MANDAL DETAILS',
                    children: [
                      _row('Category', p?.mandalCategory),
                      _row('Position', p?.mandalPosition),
                    ],
                  ),
                  _Section(
                    title: 'SPOUSE DETAILS',
                    children: [
                      if (p?.spouseName == null && p?.spouseMobile == null)
                        _row('Spouse', null)
                      else
                        _FamilyCard(
                          name: p?.spouseName ?? '—',
                          photoUrl: p?.spousePhotoUrl,
                          accent: AppColors.danger,
                          details: [
                            if (p?.spouseDob != null)
                              ('Born', Formatters.date(p!.spouseDob!)),
                            if (p?.spouseMobile != null &&
                                p!.spouseMobile!.isNotEmpty)
                              ('Mobile', p.spouseMobile!),
                            if (p?.anniversaryDate != null)
                              ('Anniversary',
                                  Formatters.date(p!.anniversaryDate!)),
                          ],
                          mobile: p?.spouseMobile,
                        ),
                    ],
                  ),
                  _Section(
                    title: 'CHILDREN',
                    children: [
                      if (bundle.children.isEmpty) _row('No children added', null),
                      for (final c in bundle.children)
                        _FamilyCard(
                          name: c.name,
                          photoUrl: c.photoUrl,
                          accent: AppColors.purple,
                          details: [
                            if (c.dob != null) ('Born', Formatters.date(c.dob!)),
                            if (c.contact != null && c.contact!.isNotEmpty)
                              ('Contact', c.contact!),
                          ],
                          mobile: c.contact,
                        ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }

  static Widget _row(String label, String? value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5, color: AppColors.textMuted)),
            ),
            Expanded(
              flex: 3,
              child: Text(value ?? '—',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ),
          ],
        ),
      );

}

/// Soft tinted card for a family member: avatar, details grid, contact actions.
class _FamilyCard extends StatelessWidget {
  const _FamilyCard({
    required this.name,
    required this.details,
    required this.accent,
    this.photoUrl,
    this.mobile,
  });

  final String name;
  final String? photoUrl;
  final Color accent;
  final List<(String, String)> details;
  final String? mobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withOpacity(0.5), width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 21,
                  backgroundColor: accent.withOpacity(0.12),
                  backgroundImage: photoUrl != null
                      ? CachedNetworkImageProvider(
                          ProfileService.resolvePhotoUrl(photoUrl!))
                      : null,
                  child: photoUrl == null
                      ? Text(name.isEmpty ? '?' : name[0].toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800, color: accent))
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(name,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ),
            ],
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final (label, value) in details)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 92,
                      child: Text(label,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5, color: AppColors.textMuted)),
                    ),
                    Expanded(
                      child: Text(value,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5, fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                    ),
                  ],
                ),
              ),
          ],
          if (mobile != null && mobile!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ContactActionRow(name: name, mobile: mobile, compact: true),
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(
      {required this.title, required this.children, this.initiallyExpanded = false});
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 8),
            iconColor: AppColors.primary,
            collapsedIconColor: AppColors.textMuted,
            title: Text(title,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w800,
                    letterSpacing: 0.8, color: AppColors.textPrimary)),
            children: children,
          ),
        ),
        const Divider(color: AppColors.border, height: 1),
      ],
    );
  }
}
