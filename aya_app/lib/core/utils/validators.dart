/// Form field validators.
class Validators {
  Validators._();

  static String? mobile(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Mobile number is required';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }
}
