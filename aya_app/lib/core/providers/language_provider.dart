import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Supported: en · hi. Persisted to secure storage key 'locale'.
class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('en') {
    _load();
  }

  static const _storage = FlutterSecureStorage();

  Future<void> _load() async {
    final saved = await _storage.read(key: 'locale');
    if (saved == 'hi' || saved == 'en') state = saved!;
  }

  Future<void> toggle() async {
    state = state == 'en' ? 'hi' : 'en';
    await _storage.write(key: 'locale', value: state);
  }
}

final languageProvider =
    StateNotifierProvider<LanguageNotifier, String>((ref) => LanguageNotifier());
