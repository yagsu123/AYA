import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/auth_service.dart' show AuthException;
import '../../../core/services/event_service.dart';
import '../../../core/services/member_directory_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/member_avatar.dart';

/// Pick the members assigned to an event (checkboxes → Done). Returns `true`
/// when the new list was saved.
class AssignMembersSheet extends StatefulWidget {
  const AssignMembersSheet({
    super.key,
    required this.eventId,
    required this.initialSelected,
  });

  final int eventId;
  final Set<int> initialSelected;

  static Future<bool?> show(BuildContext context,
      {required int eventId, required Set<int> initialSelected}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) =>
          AssignMembersSheet(eventId: eventId, initialSelected: initialSelected),
    );
  }

  @override
  State<AssignMembersSheet> createState() => _AssignMembersSheetState();
}

class _AssignMembersSheetState extends State<AssignMembersSheet> {
  List<DirectoryMember> _members = const [];
  late Set<int> _selected = {...widget.initialSelected};
  String _query = '';
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final members = await MemberDirectoryService.instance.activeMembers();
      if (mounted) setState(() {
        _members = members;
        _loading = false;
      });
    } on AuthException catch (e) {
      if (mounted) setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await EventService.instance.setAssignments(widget.eventId, _selected.toList());
      if (mounted) Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? _members
        : _members
            .where((m) =>
                m.name.toLowerCase().contains(_query) ||
                (m.mobile ?? '').contains(_query))
            .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
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
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('Assign members',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const Spacer(),
                  Text('${_selected.length} selected',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search members',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(_error!,
                              style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.textMuted)))
                      : ListView.builder(
                          controller: controller,
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final m = filtered[i];
                            final selected = _selected.contains(m.id);
                            return CheckboxListTile(
                              value: selected,
                              activeColor: AppColors.primary,
                              controlAffinity: ListTileControlAffinity.trailing,
                              onChanged: (v) => setState(() {
                                if (v == true) {
                                  _selected.add(m.id);
                                } else {
                                  _selected.remove(m.id);
                                }
                              }),
                              secondary:
                                  MemberAvatar(name: m.name, photoUrl: m.photoUrl, radius: 18),
                              title: Text(m.name,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                              subtitle: m.mobile == null
                                  ? null
                                  : Text(m.mobile!,
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5, color: AppColors.textMuted)),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Done',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
