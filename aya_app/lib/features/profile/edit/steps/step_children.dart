import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/profile_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../profile_provider.dart';
import '../date_field.dart';
import '../photo_picker_field.dart';

class StepChildren extends ConsumerWidget {
  const StepChildren({super.key});

  Future<void> _addChildSheet(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    DateTime? dob;
    String? photoUrl;
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add child',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                PhotoPickerField(
                  type: 'child',
                  size: 72,
                  onUploaded: (url) => photoUrl = url,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                DateField(
                  label: 'Date of birth',
                  value: dob,
                  onChanged: (d) => setSheetState(() => dob = d),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: contactCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                      labelText: 'Contact (optional)', counterText: ''),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      await ref.read(profileProvider.notifier).addChild(
                            name: nameCtrl.text.trim(),
                            dob: dob,
                            contact: contactCtrl.text.trim(),
                            photoUrl: photoUrl,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Add child'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(profileProvider).bundle?.children ?? const <Child>[];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        OutlinedButton.icon(
          onPressed: () => _addChildSheet(context, ref),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add child'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        if (children.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text('No children added yet.',
                  style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted)),
            ),
          ),
        for (final child in children)
          Dismissible(
            key: ValueKey(child.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            onDismissed: (_) =>
                ref.read(profileProvider.notifier).deleteChild(child.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.purpleLight,
                    backgroundImage: child.photoUrl != null
                        ? CachedNetworkImageProvider(
                            ProfileService.resolvePhotoUrl(child.photoUrl!))
                        : null,
                    child: child.photoUrl == null
                        ? Text(child.name.isEmpty ? '?' : child.name[0].toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700, color: AppColors.purple))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(child.name,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        Text(
                          [
                            if (child.dob != null) 'Born ${Formatters.date(child.dob!)}',
                            if (child.contact != null && child.contact!.isNotEmpty)
                              child.contact!,
                          ].join(' · '),
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.swipe_left_outlined,
                      size: 16, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
