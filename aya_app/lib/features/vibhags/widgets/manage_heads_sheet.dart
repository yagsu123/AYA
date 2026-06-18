import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/admin_service.dart';
import '../../../core/services/auth_service.dart' show AuthException;
import '../../../core/services/vibhag_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/member_avatar.dart';

/// Admin tool to appoint or remove a vibhag's heads. Invokes [onChanged]
/// whenever the head list changes so the caller can refresh.
class ManageHeadsSheet extends StatefulWidget {
  const ManageHeadsSheet({
    super.key,
    required this.vibhagType,
    required this.vibhagName,
    required this.initialHeads,
    required this.onChanged,
  });

  final String vibhagType;
  final String vibhagName;
  final List<VibhagHead> initialHeads;
  final VoidCallback onChanged;

  static Future<void> show(
    BuildContext context, {
    required String vibhagType,
    required String vibhagName,
    required List<VibhagHead> heads,
    required VoidCallback onChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => ManageHeadsSheet(
        vibhagType: vibhagType,
        vibhagName: vibhagName,
        initialHeads: heads,
        onChanged: onChanged,
      ),
    );
  }

  @override
  State<ManageHeadsSheet> createState() => _ManageHeadsSheetState();
}

class _ManageHeadsSheetState extends State<ManageHeadsSheet> {
  late List<VibhagHead> _heads = List.of(widget.initialHeads);
  List<AdminMember> _members = const [];
  bool _loadingMembers = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final members = await AdminService.instance.members();
      if (mounted) {
        setState(() {
          _members = members.where((m) => m.isActive).toList();
          _loadingMembers = false;
        });
      }
    } on AuthException {
      if (mounted) setState(() => _loadingMembers = false);
    }
  }

  Future<void> _add(int memberId) async {
    setState(() => _busy = true);
    try {
      final heads = await VibhagService.instance.addHead(widget.vibhagType, memberId);
      widget.onChanged();
      setState(() {
        _heads = heads;
        _busy = false;
      });
    } on AuthException catch (e) {
      setState(() => _busy = false);
      _toast(e.message);
    }
  }

  Future<void> _remove(int memberId) async {
    setState(() => _busy = true);
    try {
      final heads = await VibhagService.instance.removeHead(widget.vibhagType, memberId);
      widget.onChanged();
      setState(() {
        _heads = heads;
        _busy = false;
      });
    } on AuthException catch (e) {
      setState(() => _busy = false);
      _toast(e.message);
    }
  }

  void _toast(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final headIds = _heads.map((h) => h.memberId).toSet();
    final available =
        _members.where((m) => !headIds.contains(m.id)).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),
            Text('${widget.vibhagName} heads',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  _sectionLabel('Current heads'),
                  const SizedBox(height: 8),
                  if (_heads.isEmpty)
                    _empty('No heads appointed yet.')
                  else
                    for (final h in _heads) _headRow(h),
                  const SizedBox(height: 20),
                  _sectionLabel('Add a head'),
                  const SizedBox(height: 8),
                  if (_loadingMembers)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ))
                  else if (available.isEmpty)
                    _empty('No more active members to add.')
                  else
                    for (final m in available) _memberRow(m),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: AppColors.textMuted));

  Widget _empty(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(text,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: AppColors.textMuted)),
      );

  Widget _headRow(VibhagHead h) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            MemberAvatar(name: h.fullName, photoUrl: h.photoUrl, radius: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h.fullName,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  if (h.mobile != null)
                    Text(h.mobile!,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5, color: AppColors.textMuted)),
                ],
              ),
            ),
            IconButton(
              onPressed: _busy ? null : () => _remove(h.memberId),
              icon: const Icon(Icons.remove_circle_outline_rounded,
                  color: AppColors.danger),
            ),
          ],
        ),
      );

  Widget _memberRow(AdminMember m) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            MemberAvatar(name: m.mobile, radius: 18, color: AppColors.purple),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.mobile,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  Text(m.role[0].toUpperCase() + m.role.substring(1),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5, color: AppColors.textMuted)),
                ],
              ),
            ),
            TextButton(
              onPressed: _busy ? null : () => _add(m.id),
              child: Text('Add',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
          ],
        ),
      );
}
