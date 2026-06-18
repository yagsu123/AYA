import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/vibhag_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/vibhag_visuals.dart';
import '../vibhags_provider.dart';

class VibhagsHubScreen extends ConsumerWidget {
  const VibhagsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vibhagsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text('Vibhags',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
      ),
      body: state.loading && state.data == null
          ? const Center(child: CircularProgressIndicator())
          : state.data == null
              ? Center(
                  child: Text(state.error ?? 'Could not load vibhags.',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted)))
              : RefreshIndicator(
                  onRefresh: () => ref.read(vibhagsProvider.notifier).load(),
                  child: GridView.builder(
                    padding: EdgeInsets.all(Responsive.padding(context)),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Responsive.isMobile(context) ? 2 : 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.92,
                    ),
                    itemCount: state.data!.items.length,
                    itemBuilder: (_, i) => _VibhagTile(
                      vibhag: state.data!.items[i],
                      onTap: () => context
                          .push('/vibhags/${state.data!.items[i].type}')
                          .then((_) => ref.read(vibhagsProvider.notifier).load()),
                    ),
                  ),
                ),
    );
  }
}

class _VibhagTile extends StatelessWidget {
  const _VibhagTile({required this.vibhag, required this.onTap});
  final Vibhag vibhag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = VibhagVisuals.color(vibhag.color);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(VibhagVisuals.icon(vibhag.icon), color: accent, size: 24),
              ),
              const SizedBox(height: 12),
              Text(vibhag.name,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  vibhag.description ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5, height: 1.35, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.event_rounded, size: 13, color: accent),
                  const SizedBox(width: 4),
                  Text('${vibhag.upcomingCount} upcoming',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
