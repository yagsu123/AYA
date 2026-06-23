import 'package:dio/dio.dart';
import '../config/app_environment.dart';
import 'storage_service.dart';

/// Dio client with:
/// - Bearer token attachment from secure storage
/// - automatic refresh-and-retry on 401
/// - logout callback when refresh fails or account is inactive
class ApiService {
  ApiService._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppEnvironment.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(_AuthInterceptor(_dio));
  }

  static final ApiService instance = ApiService._();
  late final Dio _dio;
  Dio get dio => _dio;

  /// Called by the interceptor when the session is no longer valid.
  /// reason: 'inactive' (account deactivated) or 'expired' (refresh failed).
  void Function(String reason)? onSessionExpired;
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._dio);
  final Dio _dio;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra['skipAuth'] != true) {
      final jwt = await StorageService.instance.jwt;
      if (jwt != null) options.headers['Authorization'] = 'Bearer $jwt';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final isAuthCall = err.requestOptions.path.contains('/auth/login') ||
        err.requestOptions.path.contains('/auth/refresh');

    // Inactive account → hard logout.
    if (status == 403 &&
        err.response?.data is Map &&
        err.response?.data['code'] == 'ACCOUNT_INACTIVE') {
      await StorageService.instance.clearTokens();
      ApiService.instance.onSessionExpired?.call('inactive');
      return handler.next(err);
    }

    // Expired access token → try refresh once, then retry original request.
    if (status == 401 &&
        !isAuthCall &&
        err.requestOptions.extra['retried'] != true) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        try {
          final opts = err.requestOptions..extra['retried'] = true;
          final jwt = await StorageService.instance.jwt;
          opts.headers['Authorization'] = 'Bearer $jwt';
          final response = await _dio.fetch(opts);
          return handler.resolve(response);
        } catch (_) {/* fall through */}
      }
      await StorageService.instance.clearTokens();
      ApiService.instance.onSessionExpired?.call('expired');
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    final refreshToken = await StorageService.instance.refreshToken;
    if (refreshToken == null) return false;
    try {
      final res = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(extra: {'skipAuth': true}),
      );
      await StorageService.instance.saveTokens(
        jwt: res.data['token'],
        refreshToken: res.data['refreshToken'],
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
