import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/admin_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/member_list_tile.dart';
import '../../auth/auth_provider.dart';
import 'add_member_sheet.dart';
import 'admin_provider.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).load());
  }

  Future<void> _confirmLogout() async {
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

  Future<void> _confirmToggle(AdminMember member, bool toActive) async {
    final action = toActive ? 'activate' : 'deactivate';
    final confirmed = await showPlatformDialog<bool>(
      context: context,
      builder: (ctx) => PlatformAlertDialog(
        title: Text('${action[0].toUpperCase()}${action.substring(1)} member?'),
        content: Text(toActive
            ? '${member.mobile} will be able to sign in again.'
            : '${member.mobile} will be signed out and blocked from the app.'),
        actions: [
          PlatformDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          PlatformDialogAction(
            cupertino: (_, __) => CupertinoDialogActionData(isDestructiveAction: !toActive),
            child: Text(action[0].toUpperCase() + action.substring(1)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(adminProvider.notifier)
          .setStatus(member.id, toActive ? 'active' : 'inactive');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(adminProvider).error ?? 'Failed to update status.')),
        );
      }
    }
  }

  Future<void> _confirmDelete(AdminMember member) async {
    final confirmed = await showPlatformDialog<bool>(
      context: context,
      builder: (ctx) => PlatformAlertDialog(
        title: const Text('Delete member?'),
        content: Text(
            '${member.mobile} will be removed from the list and signed out. '
            'This frees a slot; the number can be added again later.'),
        actions: [
          PlatformDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          PlatformDialogAction(
            cupertino: (_, __) => CupertinoDialogActionData(isDestructiveAction: true),
            child: const Text('Delete'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(adminProvider.notifier).deleteMember(member.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(adminProvider).error ?? 'Failed to delete member.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final pad = Responsive.padding(context);
    final stats = state.stats;
    final limitReached = stats?.limitReached ?? false;

    return PlatformScaffold(
      backgroundColor: AppColors.background,
      appBar: PlatformAppBar(
        title: Text('Admin Panel',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: AppColors.primary,
        trailingActions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            tooltip: 'Sign out',
            onPressed: _confirmLogout,
          ),
        ],
        material: (_, __) => MaterialAppBarData(
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminProvider.notifier).load(),
        child: state.loading && state.members.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.all(pad),
                children: [
                  // Stats row
                  if (stats != null)
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Active members',
                            value: '${stats.active} / ${stats.limit}',
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: limitReached ? 'Limit reached' : 'Remaining slots',
                            value: '${stats.remaining}',
                            color: limitReached ? AppColors.danger : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Limit banner
                  if (limitReached) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.danger.withOpacity(0.35)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppColors.danger, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Maximum member limit reached.',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5, fontWeight: FontWeight.w600,
                                    color: AppColors.danger)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Add member
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: limitReached ? null : () => AddMemberSheet.show(context),
                      icon: const Icon(Icons.person_add_alt_1, size: 18),
                      label: const Text('Add Member'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Community management — reach the Events & Vibhags screens
                  // (where events are created, edited and sponsored).
                  Text('MANAGE',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          letterSpacing: 0.66, color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _AdminNavButton(
                          icon: Icons.event_outlined,
                          label: 'Events',
                          onTap: () => context.push('/events'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AdminNavButton(
                          icon: Icons.groups_2_outlined,
                          label: 'Vibhags',
                          onTap: () => context.push('/vibhags'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AdminNavButton(
                          icon: Icons.photo_library_outlined,
                          label: 'Gallery',
                          onTap: () => context.push('/gallery'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AdminNavButton(
                          icon: Icons.account_balance_outlined,
                          label: 'AES',
                          onTap: () => context.push('/aes'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Member list
                  Text('MEMBERS',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          letterSpacing: 0.66, color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  if (state.error != null && state.members.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(state.error!,
                            style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted)),
                      ),
                    ),
                  for (final m in state.members)
                    MemberListTile(
                      member: m,
                      onToggle: (v) => _confirmToggle(m, v),
                      onDelete: () => _confirmDelete(m),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}

class _AdminNavButton extends StatelessWidget {
  const _AdminNavButton(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(height: 8),
              Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
