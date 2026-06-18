import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';

/// Read-only text field that opens a date picker.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.validator,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? Function(DateTime?)? validator;

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      validator: (_) => validator?.call(value),
      builder: (field) => InkWell(
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime(now.year - 25),
            firstDate: firstDate ?? DateTime(1930),
            lastDate: lastDate ?? now,
          );
          if (picked != null) {
            onChanged(picked);
            field.didChange(picked);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            errorText: field.errorText,
            prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
          ),
          child: Text(value == null ? ' ' : Formatters.date(value!)),
        ),
      ),
    );
  }
}
