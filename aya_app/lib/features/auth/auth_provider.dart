import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/messenger.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/profile_service.dart';
import '../../core/services/storage_service.dart';

enum AuthStatus { unknown, unauthenticated, loading, authenticated, error }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.member,
    this.errorCode,
    this.errorMessage,
    this.needsProfileCompletion = false,
  });

  final AuthStatus status;
  final Member? member;
  final String? errorCode;
  final String? errorMessage;
  final bool needsProfileCompletion;

  AuthState copyWith(
          {AuthStatus? status,
          Member? member,
          String? errorCode,
          String? errorMessage,
          bool? needsProfileCompletion}) =>
      AuthState(
        status: status ?? this.status,
        member: member ?? this.member,
        errorCode: errorCode,
        errorMessage: errorMessage,
        needsProfileCompletion:
            needsProfileCompletion ?? this.needsProfileCompletion,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    // Kicked out by interceptor (refresh failed / account inactive).
    ApiService.instance.onSessionExpired = (reason) {
      if (state.status == AuthStatus.authenticated) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        showGlobalSnackBar(reason == 'inactive'
            ? 'Your account has been deactivated. Contact administrator.'
            : 'Session expired. Please sign in again.');
      }
    };
  }

  /// App start: read JWT → GET /auth/me → authenticated or unauthenticated.
  Future<void> bootstrap() async {
    final jwt = await StorageService.instance.jwt;
    if (jwt == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final member = await AuthService.instance.me();
      if (member != null) {
        final needsCompletion = await _checkProfileCompletion();
        state = AuthState(
            status: AuthStatus.authenticated,
            member: member,
            needsProfileCompletion: needsCompletion);
      } else {
        await StorageService.instance.clearTokens();
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } on AuthException {
      // Network error at startup: token exists but can't verify — go to login.
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String mobile, String password, {required bool rememberMe}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final member = await AuthService.instance.login(mobile, password);
      if (rememberMe) {
        await StorageService.instance.saveMobile(mobile);
      } else {
        await StorageService.instance.clearSavedMobile();
      }
      final needsCompletion = await _checkProfileCompletion();
      state = AuthState(
          status: AuthStatus.authenticated,
          member: member,
          needsProfileCompletion: needsCompletion);
      return true;
    } on AuthException catch (e) {
      state = AuthState(status: AuthStatus.error, errorCode: e.code, errorMessage: e.message);
      return false;
    }
  }

  /// First-login detection: profile missing or (pct == 0 AND full_name null).
  Future<bool> _checkProfileCompletion() async {
    try {
      final bundle = await ProfileService.instance.me();
      return bundle.needsCompletion;
    } catch (_) {
      return false; // don't block login on a profile fetch hiccup
    }
  }

  /// Called after the completion flow finishes.
  Future<void> refreshProfileFlag() async {
    final needsCompletion = await _checkProfileCompletion();
    state = state.copyWith(needsProfileCompletion: needsCompletion);
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
