import 'package:dio/dio.dart';
import 'api_service.dart';
import 'auth_service.dart' show AuthException;

class AdminStats {
  const AdminStats({
    required this.total,
    required this.active,
    required this.inactive,
    required this.limit,
    required this.remaining,
  });

  final int total;
  final int active;
  final int inactive;
  final int limit;
  final int remaining;

  bool get limitReached => remaining <= 0;

  factory AdminStats.fromJson(Map<String, dynamic> j) => AdminStats(
        total: j['total'] as int,
        active: j['active'] as int,
        inactive: j['inactive'] as int,
        limit: j['limit'] as int,
        remaining: j['remaining'] as int,
      );
}

class AdminMember {
  const AdminMember({
    required this.id,
    required this.mobile,
    required this.role,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String mobile;
  final String role;
  final String status;
  final DateTime createdAt;

  bool get isActive => status == 'active';

  AdminMember copyWith({String? status}) => AdminMember(
        id: id,
        mobile: mobile,
        role: role,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  factory AdminMember.fromJson(Map<String, dynamic> j) => AdminMember(
        id: j['id'] as int,
        mobile: j['mobile'] as String,
        role: j['role'] as String,
        status: j['status'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class NewMemberResult {
  const NewMemberResult({required this.id, required this.mobile, required this.tempPassword});
  final int id;
  final String mobile;
  final String tempPassword;
}

class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();

  Dio get _dio => ApiService.instance.dio;

  Future<AdminStats> stats() async {
    try {
      final res = await _dio.get('/admin/stats');
      return AdminStats.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<List<AdminMember>> members({int page = 1, int limit = 100}) async {
    try {
      final res = await _dio.get('/admin/members',
          queryParameters: {'page': page, 'limit': limit});
      return (res.data['items'] as List)
          .map((e) => AdminMember.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<NewMemberResult> addMember(String mobile) async {
    try {
      final res = await _dio.post('/admin/members', data: {'mobile': mobile});
      return NewMemberResult(
        id: res.data['id'] as int,
        mobile: res.data['mobile'] as String,
        tempPassword: res.data['tempPassword'] as String,
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> setStatus(int id, String status) async {
    try {
      await _dio.patch('/admin/members/$id/status', data: {'status': status});
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> deleteMember(int id) async {
    try {
      await _dio.delete('/admin/members/$id');
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  AuthException _map(DioException e) {
    final data = e.response?.data;
    if (e.response == null) {
      return const AuthException('NETWORK', 'Connection failed. Please try again.');
    }
    if (data is Map && data['code'] != null) {
      return AuthException(
          data['code'] as String, (data['message'] ?? 'Something went wrong.') as String);
    }
    return const AuthException('UNKNOWN', 'Something went wrong.');
  }
}
