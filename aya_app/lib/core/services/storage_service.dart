import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage wrapper — JWTs live here, never in SharedPreferences.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const _kJwt = 'jwt';
  static const _kRefresh = 'refresh_token';
  static const _kSavedMobile = 'saved_mobile';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<String?> get jwt => _storage.read(key: _kJwt);
  Future<String?> get refreshToken => _storage.read(key: _kRefresh);
  Future<String?> get savedMobile => _storage.read(key: _kSavedMobile);

  Future<void> saveTokens({required String jwt, required String refreshToken}) async {
    await _storage.write(key: _kJwt, value: jwt);
    await _storage.write(key: _kRefresh, value: refreshToken);
  }

  Future<void> saveMobile(String mobile) => _storage.write(key: _kSavedMobile, value: mobile);
  Future<void> clearSavedMobile() => _storage.delete(key: _kSavedMobile);

  /// Clears auth tokens but keeps saved_mobile (Remember Me survives logout).
  Future<void> clearTokens() async {
    await _storage.delete(key: _kJwt);
    await _storage.delete(key: _kRefresh);
  }
}
