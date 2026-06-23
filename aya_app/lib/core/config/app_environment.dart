import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Resolves runtime configuration into values that are safe for app services.
class AppEnvironment {
  AppEnvironment._();

  static const _developmentApiBaseUrl = 'http://10.0.2.2:3000/api';

  static String get apiBaseUrl {
    const buildTimeValue = String.fromEnvironment('API_BASE_URL');
    final configuredValue = buildTimeValue.trim().isNotEmpty
        ? buildTimeValue
        : dotenv.env['API_BASE_URL'];

    return normalizeApiBaseUrl(configuredValue);
  }

  static String normalizeApiBaseUrl(String? configuredValue) {
    var value = configuredValue?.trim() ?? '';
    if (value.isEmpty) return _developmentApiBaseUrl;

    value = value.replaceAll(RegExp(r'/+$'), '');
    if (!value.contains('://')) {
      value = '${_schemeFor(value)}://$value';
    }

    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return _developmentApiBaseUrl;
    }

    final normalizedPath = uri.path.isEmpty || uri.path == '/'
        ? '/api'
        : uri.path.replaceAll(RegExp(r'/+$'), '');

    return uri.replace(path: normalizedPath).toString();
  }

  static String _schemeFor(String value) {
    final host = value.split('/').first.split(':').first.toLowerCase();
    final isLocalHost = host == 'localhost' || host == '127.0.0.1';
    final isPrivateNetwork = host.startsWith('10.') ||
        host.startsWith('192.168.') ||
        RegExp(r'^172\.(1[6-9]|2\d|3[01])\.').hasMatch(host);

    return isLocalHost || isPrivateNetwork ? 'http' : 'https';
  }
}
