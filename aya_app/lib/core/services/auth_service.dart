import 'package:dio/dio.dart';
import 'api_service.dart';
import 'storage_service.dart';

class Member {
  const Member({required this.id, required this.mobile, required this.role});
  final int id;
  final String mobile;
  final String role;

  factory Member.fromJson(Map<String, dynamic> json) =>
      Member(id: json['id'] as int, mobile: json['mobile'] as String, role: json['role'] as String);
}

/// Thrown with a machine-readable code so the UI can map errors to fields.
class AuthException implements Exception {
  const AuthException(this.code, this.message);
  final String code; // MOBILE_NOT_FOUND | ACCOUNT_INACTIVE | INCORRECT_PASSWORD | INVALID_OTP | NETWORK | UNKNOWN
  final String message;
}

/// Outcome of a login attempt: either the member is authenticated, or they are
/// signing in for the first time and must enrol an authenticator app first.
class LoginResult {
  const LoginResult._({this.member, this.otpauthUrl, this.secret});

  final Member? member;
  final String? otpauthUrl;
  final String? secret;

  bool get totpSetupRequired => member == null;

  factory LoginResult.authenticated(Member member) => LoginResult._(member: member);

  factory LoginResult.totpSetup({required String otpauthUrl, required String secret}) =>
      LoginResult._(otpauthUrl: otpauthUrl, secret: secret);
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Dio get _dio => ApiService.instance.dio;

  Future<LoginResult> login(String mobile, String password) async {
    try {
      final res = await _dio.post(
        '/auth/login',
        data: {'mobile': mobile, 'password': password},
        options: Options(extra: {'skipAuth': true}),
      );
      if (res.data['totpSetupRequired'] == true) {
        return LoginResult.totpSetup(
          otpauthUrl: res.data['otpauthUrl'] as String,
          secret: res.data['secret'] as String,
        );
      }
      await StorageService.instance.saveTokens(
        jwt: res.data['token'],
        refreshToken: res.data['refreshToken'],
      );
      return LoginResult.authenticated(
          Member.fromJson(res.data['member'] as Map<String, dynamic>));
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Confirms first-login authenticator enrolment with a 6-digit code and, on
  /// success, returns the now-authenticated member (tokens are stored).
  Future<Member> verifyTotpSetup({
    required String mobile,
    required String password,
    required String token,
  }) async {
    try {
      final res = await _dio.post(
        '/auth/totp/verify',
        data: {'mobile': mobile, 'password': password, 'token': token},
        options: Options(extra: {'skipAuth': true}),
      );
      await StorageService.instance.saveTokens(
        jwt: res.data['token'],
        refreshToken: res.data['refreshToken'],
      );
      return Member.fromJson(res.data['member'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Member?> me() async {
    try {
      final res = await _dio.get('/auth/me');
      return Member.fromJson(res.data['member'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) return null; // not authenticated
      throw _mapError(e);
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await StorageService.instance.refreshToken;
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (_) {
      // Even if the server call fails, clear local session.
    } finally {
      await StorageService.instance.clearTokens();
    }
  }

  AuthException _mapError(DioException e) {
    final data = e.response?.data;
    if (e.response == null) {
      return const AuthException('NETWORK', 'Connection failed. Please try again.');
    }
    if (data is Map && data['code'] != null) {
      return AuthException(data['code'] as String, (data['message'] ?? 'Something went wrong.') as String);
    }
    return const AuthException('UNKNOWN', 'Something went wrong.');
  }
}
