import 'package:aya_app/core/config/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEnvironment.normalizeApiBaseUrl', () {
    test('adds HTTPS and the API path to a public hostname', () {
      expect(
        AppEnvironment.normalizeApiBaseUrl('aya.example.com'),
        'https://aya.example.com/api',
      );
    });

    test('keeps an explicitly configured API path', () {
      expect(
        AppEnvironment.normalizeApiBaseUrl('https://aya.example.com/api/'),
        'https://aya.example.com/api',
      );
    });

    test('uses HTTP for a private development server', () {
      expect(
        AppEnvironment.normalizeApiBaseUrl('192.168.1.20:3000'),
        'http://192.168.1.20:3000/api',
      );
    });

    test('falls back to the Android emulator server when empty', () {
      expect(
        AppEnvironment.normalizeApiBaseUrl(''),
        'http://10.0.2.2:3000/api',
      );
    });
  });
}
