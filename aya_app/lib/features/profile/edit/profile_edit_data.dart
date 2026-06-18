import 'package:flutter/material.dart';
import '../../../core/services/profile_service.dart';

/// Shared mutable state for the 5-step completion flow.
class ProfileEditData {
  final fullName = TextEditingController();
  final email = TextEditingController();
  final nativePlace = TextEditingController();
  final resAddress = TextEditingController();
  final resPhone = TextEditingController();
  final officeAddress = TextEditingController();
  final officePhone = TextEditingController();
  final mandalPosition = TextEditingController();
  final spouseName = TextEditingController();
  final spouseMobile = TextEditingController();

  DateTime? dob;
  DateTime? anniversaryDate;
  DateTime? spouseDob;
  String? bloodGroup;
  String? mandalCategory;
  String? photoUrl;
  String? spousePhotoUrl;
  String role = 'member';
  String roleStatus = 'approved';

  void prefill(ProfileBundle bundle) {
    final p = bundle.profile;
    if (p != null) {
      fullName.text = p.fullName ?? '';
      email.text = p.email ?? '';
      nativePlace.text = p.nativePlace ?? '';
      resAddress.text = p.resAddress ?? '';
      resPhone.text = p.resPhone ?? '';
      officeAddress.text = p.officeAddress ?? '';
      officePhone.text = p.officePhone ?? '';
      mandalPosition.text = p.mandalPosition ?? '';
      spouseName.text = p.spouseName ?? '';
      spouseMobile.text = p.spouseMobile ?? '';
      dob = p.dob;
      anniversaryDate = p.anniversaryDate;
      spouseDob = p.spouseDob;
      bloodGroup = p.bloodGroup;
      mandalCategory = p.mandalCategory;
      photoUrl = p.photoUrl;
      spousePhotoUrl = p.spousePhotoUrl;
    }
    role = bundle.role ?? 'member';
    roleStatus = bundle.roleStatus ?? 'approved';
  }

  String? _t(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
  String? _date(DateTime? d) => d?.toIso8601String().substring(0, 10);

  /// All fields for PUT /api/profile/me.
  Map<String, dynamic> toJson() => {
        'full_name': _t(fullName),
        'email': _t(email),
        'dob': _date(dob),
        'anniversary_date': _date(anniversaryDate),
        'native_place': _t(nativePlace),
        'blood_group': bloodGroup,
        'res_address': _t(resAddress),
        'res_phone': _t(resPhone),
        'office_address': _t(officeAddress),
        'office_phone': _t(officePhone),
        'mandal_category': mandalCategory,
        'mandal_position': _t(mandalPosition),
        'spouse_name': _t(spouseName),
        'spouse_mobile': _t(spouseMobile),
        'spouse_dob': _date(spouseDob),
      };

  void dispose() {
    for (final c in [
      fullName, email, nativePlace, resAddress, resPhone,
      officeAddress, officePhone, mandalPosition, spouseName, spouseMobile,
    ]) {
      c.dispose();
    }
  }
}
