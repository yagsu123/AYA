import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../date_field.dart';
import '../photo_picker_field.dart';
import '../profile_edit_data.dart';

const bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

class StepPersonal extends StatelessWidget {
  const StepPersonal({super.key, required this.data, required this.onChanged});

  final ProfileEditData data;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        PhotoPickerField(
          type: 'member',
          initialUrl: data.photoUrl,
          onUploaded: (url) {
            data.photoUrl = url;
            onChanged();
          },
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: data.fullName,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
              labelText: 'Full name', prefixIcon: Icon(Icons.person_outline, size: 20)),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: data.email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
              labelText: 'Email', prefixIcon: Icon(Icons.mail_outline, size: 20)),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null; // optional
            return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())
                ? null
                : 'Enter a valid email';
          },
        ),
        const SizedBox(height: 16),
        DateField(
          label: 'Date of birth',
          value: data.dob,
          onChanged: (d) {
            data.dob = d;
            onChanged();
          },
          validator: (d) => d == null ? 'Date of birth is required' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: data.bloodGroup,
          decoration: const InputDecoration(
              labelText: 'Blood group',
              prefixIcon: Icon(Icons.bloodtype_outlined, size: 20)),
          items: [
            for (final g in bloodGroups) DropdownMenuItem(value: g, child: Text(g)),
          ],
          onChanged: (v) {
            data.bloodGroup = v;
            onChanged();
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: data.nativePlace,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
              labelText: 'Native place',
              prefixIcon: Icon(Icons.location_on_outlined, size: 20)),
        ),
      ],
    );
  }
}
