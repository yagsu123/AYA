import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../date_field.dart';
import '../photo_picker_field.dart';
import '../profile_edit_data.dart';

class StepSpouse extends StatelessWidget {
  const StepSpouse({super.key, required this.data, required this.onChanged});

  final ProfileEditData data;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('All fields optional — use Skip if not applicable.',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 16),
        PhotoPickerField(
          type: 'spouse',
          initialUrl: data.spousePhotoUrl,
          onUploaded: (url) {
            data.spousePhotoUrl = url;
            onChanged();
          },
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: data.spouseName,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
              labelText: 'Spouse name', prefixIcon: Icon(Icons.person_outline, size: 20)),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: data.spouseMobile,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: const InputDecoration(
              labelText: 'Spouse mobile', counterText: '',
              prefixIcon: Icon(Icons.call_outlined, size: 20)),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            return RegExp(r'^[0-9]{10}$').hasMatch(v.trim())
                ? null : 'Enter a valid 10-digit number';
          },
        ),
        const SizedBox(height: 16),
        DateField(
          label: 'Spouse date of birth',
          value: data.spouseDob,
          onChanged: (d) {
            data.spouseDob = d;
            onChanged();
          },
        ),
        const SizedBox(height: 16),
        DateField(
          label: 'Anniversary date',
          value: data.anniversaryDate,
          onChanged: (d) {
            data.anniversaryDate = d;
            onChanged();
          },
        ),
      ],
    );
  }
}
