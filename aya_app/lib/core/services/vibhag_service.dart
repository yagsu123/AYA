import 'package:dio/dio.dart';
import 'api_service.dart';
import 'auth_service.dart' show AuthException;
import 'event_service.dart';

class Vibhag {
  const Vibhag({
    required this.type,
    required this.name,
    this.description,
    this.color,
    this.icon,
    this.headCount = 0,
    this.upcomingCount = 0,
  });

  final String type;
  final String name;
  final String? description;
  final String? color;
  final String? icon;
  final int headCount;
  final int upcomingCount;

  factory Vibhag.fromJson(Map<String, dynamic> j) => Vibhag(
        type: j['type'] as String,
        name: (j['name'] ?? '') as String,
        description: j['description'] as String?,
        color: j['color'] as String?,
        icon: j['icon'] as String?,
        headCount: (j['head_count'] ?? 0) as int,
        upcomingCount: (j['upcoming_count'] ?? 0) as int,
      );
}

class VibhagHead {
  const VibhagHead({
    required this.memberId,
    required this.fullName,
    this.mobile,
    this.photoUrl,
    this.role,
  });

  final int memberId;
  final String fullName;
  final String? mobile;
  final String? photoUrl;
  final String? role;

  factory VibhagHead.fromJson(Map<String, dynamic> j) => VibhagHead(
        memberId: j['member_id'] as int,
        fullName: (j['full_name'] ?? '') as String,
        mobile: j['mobile'] as String?,
        photoUrl: j['photo_url'] as String?,
        role: j['role'] as String?,
      );
}

/// The vibhag catalogue plus what the caller may manage.
class VibhagList {
  const VibhagList({
    required this.items,
    required this.myHeadTypes,
    required this.isAdmin,
  });

  final List<Vibhag> items;
  final List<String> myHeadTypes;
  final bool isAdmin;

  bool canManage(String type) => isAdmin || myHeadTypes.contains(type);
  bool get canManageAny => isAdmin || myHeadTypes.isNotEmpty;
}

class VibhagDetail {
  const VibhagDetail({
    required this.vibhag,
    required this.heads,
    required this.upcoming,
    required this.past,
    required this.canManage,
  });

  final Vibhag vibhag;
  final List<VibhagHead> heads;
  final List<AppEvent> upcoming;
  final List<AppEvent> past;
  final bool canManage;
}

class VibhagService {
  VibhagService._();
  static final VibhagService instance = VibhagService._();

  Dio get _dio => ApiService.instance.dio;

  Future<VibhagList> list() async {
    try {
      final res = await _dio.get('/vibhags');
      final data = res.data as Map<String, dynamic>;
      return VibhagList(
        items: (data['items'] as List)
            .map((e) => Vibhag.fromJson(e as Map<String, dynamic>))
            .toList(),
        myHeadTypes:
            (data['my_head_types'] as List).map((e) => e as String).toList(),
        isAdmin: (data['is_admin'] ?? false) as bool,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<VibhagDetail> detail(String type) async {
    try {
      final res = await _dio.get('/vibhags/$type');
      final data = res.data as Map<String, dynamic>;
      return VibhagDetail(
        vibhag: Vibhag.fromJson(data['vibhag'] as Map<String, dynamic>),
        heads: (data['heads'] as List)
            .map((e) => VibhagHead.fromJson(e as Map<String, dynamic>))
            .toList(),
        upcoming: (data['upcoming'] as List)
            .map((e) => AppEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
        past: (data['past'] as List)
            .map((e) => AppEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
        canManage: (data['can_manage'] ?? false) as bool,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<VibhagHead>> addHead(String type, int memberId) async {
    try {
      final res = await _dio.post('/vibhags/$type/heads', data: {'member_id': memberId});
      return (res.data['heads'] as List)
          .map((e) => VibhagHead.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<VibhagHead>> removeHead(String type, int memberId) async {
    try {
      final res = await _dio.delete('/vibhags/$type/heads/$memberId');
      return (res.data['heads'] as List)
          .map((e) => VibhagHead.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  AuthException _mapError(DioException e) {
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
