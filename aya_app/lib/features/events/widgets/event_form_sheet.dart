import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/auth_service.dart' show AuthException;
import '../../../core/services/event_service.dart';
import '../../../core/services/vibhag_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/vibhag_visuals.dart';

/// Create or edit an event. Returns `true` when something was saved.
class EventFormSheet extends StatefulWidget {
  const EventFormSheet({
    super.key,
    this.event,
    this.manageableVibhags = const [],
    this.lockedVibhagType,
  });

  final AppEvent? event;
  final List<Vibhag> manageableVibhags;
  final String? lockedVibhagType;

  static Future<bool?> show(
    BuildContext context, {
    AppEvent? event,
    List<Vibhag> manageableVibhags = const [],
    String? lockedVibhagType,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => EventFormSheet(
        event: event,
        manageableVibhags: manageableVibhags,
        lockedVibhagType: lockedVibhagType,
      ),
    );
  }

  @override
  State<EventFormSheet> createState() => _EventFormSheetState();
}

class _EventFormSheetState extends State<EventFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _venue;
  late final TextEditingController _description;

  String? _vibhagType;
  DateTime? _date;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _saving = false;

  bool get _isEdit => widget.event != null;
  bool get _vibhagLocked => _isEdit || widget.lockedVibhagType != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _name = TextEditingController(text: e?.name ?? '');
    _venue = TextEditingController(text: e?.venue ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _vibhagType = e?.vibhagType ??
        widget.lockedVibhagType ??
        (widget.manageableVibhags.isNotEmpty
            ? widget.manageableVibhags.first.type
            : null);
    _date = e?.date;
    _endDate = e?.endDate;
    _startTime = _parse(e?.time);
    _endTime = _parse(e?.endTime);
  }

  TimeOfDay? _parse(String? hhmm) {
    if (hhmm == null) return null;
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
  }

  @override
  void dispose() {
    _name.dispose();
    _venue.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final start = _date ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? start,
      firstDate: start,
      lastDate: DateTime(start.year + 5),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
        context: context, initialTime: _startTime ?? TimeOfDay.now());
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
        context: context, initialTime: _endTime ?? _startTime ?? TimeOfDay.now());
    if (picked != null) setState(() => _endTime = picked);
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_vibhagType == null) return _toast('Please choose a vibhag.');
    if (_date == null) return _toast('Please choose the start date.');
    if (_startTime == null) return _toast('Please choose the start time.');

    setState(() => _saving = true);
    try {
      final endStr = _endTime == null ? null : _fmt(_endTime!);
      if (_isEdit) {
        await EventService.instance.update(
          widget.event!.id,
          name: _name.text.trim(),
          date: _date!,
          endDate: _endDate,
          time: _fmt(_startTime!),
          endTime: endStr,
          venue: _venue.text.trim(),
          description: _description.text.trim(),
        );
      } else {
        await EventService.instance.create(
          vibhagType: _vibhagType!,
          name: _name.text.trim(),
          date: _date!,
          endDate: _endDate,
          time: _fmt(_startTime!),
          endTime: endStr,
          venue: _venue.text.trim(),
          description: _description.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      setState(() => _saving = false);
      _toast(e.message);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(_isEdit ? 'Edit event' : 'New event',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              if (!_vibhagLocked) ...[
                _label('Vibhag'),
                const SizedBox(height: 8),
                _vibhagPicker(),
                const SizedBox(height: 16),
              ],
              _label('Event name'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: _input('e.g. Snatra Mahapuja'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Event name is required.' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _pickerField('Start date',
                        _date == null ? 'Choose' : Formatters.date(_date!),
                        Icons.calendar_today_rounded, _pickDate),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _pickerField('End date (optional)',
                        _endDate == null ? 'Same day' : Formatters.date(_endDate!),
                        Icons.event_repeat_rounded, _pickEndDate,
                        onClear:
                            _endDate == null ? null : () => setState(() => _endDate = null)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _pickerField('Start time',
                        _startTime == null ? 'Choose' : _startTime!.format(context),
                        Icons.schedule_rounded, _pickStartTime),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _pickerField('End time (optional)',
                        _endTime == null ? 'Open' : _endTime!.format(context),
                        Icons.schedule_outlined, _pickEndTime,
                        onClear:
                            _endTime == null ? null : () => setState(() => _endTime = null)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _label('Venue'),
              const SizedBox(height: 6),
              TextFormField(
                  controller: _venue, decoration: _input('e.g. Jain Upashraya')),
              const SizedBox(height: 16),
              _label('Details (optional)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _description,
                maxLines: 3,
                decoration: _input('Anything members should know'),
              ),
              const SizedBox(height: 20),
              SizedBox(
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
                      : Text(_isEdit ? 'Save changes' : 'Create event',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vibhagPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final v in widget.manageableVibhags)
          _VibhagChoice(
            vibhag: v,
            selected: v.type == _vibhagType,
            onTap: () => setState(() => _vibhagType = v.type),
          ),
      ],
    );
  }

  Widget _pickerField(String label, String value, IconData icon, VoidCallback onTap,
      {VoidCallback? onClear}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, color: AppColors.textPrimary)),
                ),
                if (onClear != null)
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.plusJakartaSans(
          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted));

  InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );
}

class _VibhagChoice extends StatelessWidget {
  const _VibhagChoice(
      {required this.vibhag, required this.selected, required this.onTap});
  final Vibhag vibhag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = VibhagVisuals.color(vibhag.color);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.14) : AppColors.background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: selected ? accent : AppColors.border,
              width: selected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(VibhagVisuals.icon(vibhag.icon), size: 15, color: accent),
            const SizedBox(width: 6),
            Text(vibhag.name,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? accent : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
