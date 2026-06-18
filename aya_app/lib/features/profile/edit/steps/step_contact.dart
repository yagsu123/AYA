import 'package:flutter/material.dart';

import '../profile_edit_data.dart';

class StepContact extends StatelessWidget {
  const StepContact({super.key, required this.data});

  final ProfileEditData data;

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return null; // optional
    return RegExp(r'^[0-9]{10}$').hasMatch(v.trim())
        ? null
        : 'Enter a valid 10-digit number';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        TextFormField(
          controller: data.resAddress,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
              labelText: 'Residential address', alignLabelWithHint: true,
              prefixIcon: Icon(Icons.home_outlined, size: 20)),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: data.resPhone,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: const InputDecoration(
              labelText: 'Residential phone', counterText: '',
              prefixIcon: Icon(Icons.call_outlined, size: 20)),
          validator: _phoneValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: data.officeAddress,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
              labelText: 'Office address', alignLabelWithHint: true,
              prefixIcon: Icon(Icons.business_outlined, size: 20)),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: data.officePhone,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: const InputDecoration(
              labelText: 'Office phone', counterText: '',
              prefixIcon: Icon(Icons.call_outlined, size: 20)),
          validator: _phoneValidator,
        ),
      ],
    );
  }
}
