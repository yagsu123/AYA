import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/providers/language_provider.dart';
import '../../core/services/profile_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/platform_nav.dart';
import '../ads/carousel/ads_carousel.dart';
import '../auth/auth_provider.dart';
import 'dashboard_provider.dart';
import '../../core/widgets/animated_icons.dart';
import 'widgets/bento_tiles.dart';
import 'widgets/celebration_section.dart';
import 'widgets/community_banner.dart';
import 'widgets/scene_tiles.dart';

const _adminRoles = ['president', 'secretary'];

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardProvider.notifier).load());
  }

  void _soon(String locale) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get(locale, 'comingSoon'))));
  }

  void _onNavTap(int index, String locale) {
    switch (index) {
      case 0:
        return;
      case 2:
        context
            .push('/events')
            .then((_) => ref.read(dashboardProvider.notifier).load());
        return;
      case 3:
        context.push('/gallery');
        return;
      case 4:
        _showMoreSheet();
        return;
      default:
        _soon(locale); // Members directory — coming later
    }
  }

  void _showMoreSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.person_outline, color: AppColors.primary),
              title: Text('My Profile', style: GoogleFonts.plusJakartaSans()),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
              title: Text('Settings', style: GoogleFonts.plusJakartaSans()),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: Text('Sign out',
                  style: GoogleFonts.plusJakartaSans(color: AppColors.danger)),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(authProvider.notifier).logout();
                if (mounted) context.go('/login');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _greetingKey() {
    final h = DateTime.now().hour;
    if (h < 12) return 'goodMorning';
    if (h < 17) return 'goodAfternoon';
    return 'goodEvening';
  }

  static String _initials(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return '?';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final locale = ref.watch(languageProvider);
    final pad = Responsive.padding(context);
    final data = state.data;
    final isAdmin = _adminRoles.contains(ref.watch(authProvider).member?.role);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: PlatformNav(
        currentIndex: 0,
        onTap: (i) => _onNavTap(i, locale),
        items: [
          NavItem(AppStrings.get(locale, 'home'), Icons.home_outlined, Icons.home),
          NavItem(AppStrings.get(locale, 'members'), Icons.people_outline, Icons.people),
          NavItem(AppStrings.get(locale, 'events'), Icons.event_outlined, Icons.event),
          NavItem(AppStrings.get(locale, 'gallery'), Icons.photo_outlined, Icons.photo),
          NavItem(AppStrings.get(locale, 'more'), Icons.menu, Icons.menu),
        ],
      ),
      body: data == null
          ? Center(
              child: state.loading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.error ?? 'Could not load dashboard.',
                            style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textMuted)),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () =>
                              ref.read(dashboardProvider.notifier).load(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
            )
          : SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: () => ref.read(dashboardProvider.notifier).load(),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(pad, 8, pad, 24),
                  children: [
                    // ===== Top bar =====
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.push('/profile').then(
                              (_) => ref.read(dashboardProvider.notifier).load()),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.amber, Color(0xFFFFD37E)],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primaryLight,
                              backgroundImage: data.member.photoUrl != null
                                  ? CachedNetworkImageProvider(
                                      ProfileService.resolvePhotoUrl(
                                          data.member.photoUrl!))
                                  : null,
                              child: data.member.photoUrl == null
                                  ? Text(_initials(data.member.fullName),
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary))
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const FlameIcon(
                                      size: 13, color: AppColors.amber),
                                  const SizedBox(width: 4),
                                  Text(AppStrings.get(locale, _greetingKey()),
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          color: AppColors.textMuted)),
                                ],
                              ),
                              Text(
                                data.member.fullName ??
                                    data.member.mobile ??
                                    'Member',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _soon(locale),
                          icon: const Icon(Icons.notifications_none_rounded,
                              color: AppColors.textPrimary),
                        ),
                        GestureDetector(
                          onTap: () =>
                              ref.read(languageProvider.notifier).toggle(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(locale == 'en' ? 'हिंदी' : 'EN',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ===== Bento mosaic =====
                    SizedBox(
                      height: 168,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 7,
                            child: EventHeroTile(
                              event: data.nextEvent,
                              onTap: () => context
                                  .push(data.nextEvent != null
                                      ? '/events/${data.nextEvent!.id}'
                                      : '/events')
                                  .then((_) => ref
                                      .read(dashboardProvider.notifier)
                                      .load()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                Expanded(
                                  child: StatTile(
                                    icon: Icons.cake_outlined,
                                    color: AppColors.amber,
                                    value: '${data.todayBirthdays.length}',
                                    label: AppStrings.get(locale, 'birthdays'),
                                    onTap: () => context.push('/birthdays').then(
                                        (_) => ref
                                            .read(dashboardProvider.notifier)
                                            .load()),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: StatTile(
                                    icon: Icons.people_outline,
                                    color: AppColors.purple,
                                    value: '${data.membersCount}',
                                    label: AppStrings.get(locale, 'members'),
                                    onTap: () => _soon(locale),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    CompletionTile(
                      pct: data.profileCompletePct,
                      label: AppStrings.get(locale, 'completeProfile'),
                      onTap: () => context.push('/profile/complete').then(
                          (_) => ref.read(dashboardProvider.notifier).load()),
                    ),
                    if (data.profileCompletePct < 100) const SizedBox(height: 10),

                    // Quick access — animated micro-scenes (each card a tiny world)
                    SizedBox(
                      height: 118,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: SceneCard(
                              kind: SceneKind.events,
                              label: AppStrings.get(locale, 'events'),
                              accent: const Color(0xFF0D9488),
                              onTap: () => context.push('/events').then(
                                  (_) => ref.read(dashboardProvider.notifier).load()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SceneCard(
                              kind: SceneKind.gallery,
                              label: AppStrings.get(locale, 'gallery'),
                              accent: AppColors.primary,
                              onTap: () => context.push('/gallery'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 118,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: SceneCard(
                              kind: SceneKind.vibhags,
                              label: AppStrings.get(locale, 'vibhags'),
                              accent: AppColors.danger,
                              onTap: () => context.push('/vibhags').then(
                                  (_) => ref.read(dashboardProvider.notifier).load()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SceneCard(
                              kind: SceneKind.aes,
                              label: AppStrings.get(locale, 'aes'),
                              accent: AppColors.success,
                              onTap: () => context.push('/aes'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 118,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: SceneCard(
                                kind: SceneKind.admin,
                                label: 'Admin Panel',
                                accent: AppColors.primaryDark,
                                onTap: () => context.push('/admin'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    CelebrationSection(
                      title:
                          '${AppStrings.get(locale, 'todayBirthdays')} · ${_today()}',
                      entries: data.todayBirthdays,
                      icon: Icons.cake_outlined,
                      accent: AppColors.amber,
                      whatsappMessage:
                          'Happy Birthday from Aradhana Youth Association 🎉',
                      subtitleBuilder: (e) => e.years == null
                          ? AppStrings.get(locale, 'birthdayToday')
                          : AppStrings.get(locale, 'turnsToday', n: e.years),
                    ),
                    if (data.todayBirthdays.isNotEmpty)
                      const SizedBox(height: 16),

                    CelebrationSection(
                      title: AppStrings.get(locale, 'todayAnniversaries'),
                      entries: data.todayAnniversaries,
                      icon: Icons.favorite_outline,
                      accent: AppColors.danger,
                      whatsappMessage:
                          'Happy Anniversary from Aradhana Youth Association 🎉',
                      subtitleBuilder: (e) => e.years == null
                          ? AppStrings.get(locale, 'anniversaryToday')
                          : AppStrings.get(locale, 'yearsToday', n: e.years),
                    ),
                    if (data.todayAnniversaries.isNotEmpty)
                      const SizedBox(height: 16),

                    AdsCarousel(ads: data.ads),
                    if (data.ads.isNotEmpty) const SizedBox(height: 16),
                    CommunityBanner(
                      tagline: AppStrings.get(locale, 'tagline'),
                      membersCount: data.membersCount,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  static String _today() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.day}';
  }
}
