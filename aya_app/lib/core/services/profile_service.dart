import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_service.dart';
import 'auth_service.dart' show AuthException;

class Profile {
  const Profile({
    this.fullName, this.email, this.dob, this.anniversaryDate,
    this.nativePlace, this.bloodGroup, this.photoUrl,
    this.resAddress, this.resPhone, this.officeAddress, this.officePhone,
    this.mandalCategory, this.mandalPosition,
    this.spouseName, this.spouseMobile, this.spouseDob, this.spousePhotoUrl,
    this.completePct = 0,
  });

  final String? fullName;
  final String? email;
  final DateTime? dob;
  final DateTime? anniversaryDate;
  final String? nativePlace;
  final String? bloodGroup;
  final String? photoUrl;
  final String? resAddress;
  final String? resPhone;
  final String? officeAddress;
  final String? officePhone;
  final String? mandalCategory;
  final String? mandalPosition;
  final String? spouseName;
  final String? spouseMobile;
  final DateTime? spouseDob;
  final String? spousePhotoUrl;
  final int completePct;

  static DateTime? _d(dynamic v) => v == null ? null : DateTime.tryParse(v as String);

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        fullName: j['full_name'] as String?,
        email: j['email'] as String?,
        dob: _d(j['dob']),
        anniversaryDate: _d(j['anniversary_date']),
        nativePlace: j['native_place'] as String?,
        bloodGroup: j['blood_group'] as String?,
        photoUrl: j['photo_url'] as String?,
        resAddress: j['res_address'] as String?,
        resPhone: j['res_phone'] as String?,
        officeAddress: j['office_address'] as String?,
        officePhone: j['office_phone'] as String?,
        mandalCategory: j['mandal_category'] as String?,
        mandalPosition: j['mandal_position'] as String?,
        spouseName: j['spouse_name'] as String?,
        spouseMobile: j['spouse_mobile'] as String?,
        spouseDob: _d(j['spouse_dob']),
        spousePhotoUrl: j['spouse_photo_url'] as String?,
        completePct: (j['profile_complete_pct'] ?? 0) as int,
      );
}

class Child {
  const Child({required this.id, required this.name, this.dob, this.contact, this.photoUrl});

  final int id;
  final String name;
  final DateTime? dob;
  final String? contact;
  final String? photoUrl;

  factory Child.fromJson(Map<String, dynamic> j) => Child(
        id: j['id'] as int,
        name: (j['name'] ?? '') as String,
        dob: j['dob'] == null ? null : DateTime.tryParse(j['dob'] as String),
        contact: j['contact'] as String?,
        photoUrl: j['photo_url'] as String?,
      );
}

class ProfileBundle {
  const ProfileBundle(
      {this.profile, this.children = const [], this.role, this.roleStatus, this.mobile});
  final Profile? profile;
  final List<Child> children;
  final String? role;
  final String? roleStatus;
  final String? mobile;

  bool get needsCompletion =>
      profile == null || (profile!.completePct == 0 && profile!.fullName == null);
}

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  Dio get _dio => ApiService.instance.dio;

  /// Photos may come back as relative paths (/uploads/...) when the backend
  /// stores them locally. Resolve against the API host.
  static String resolvePhotoUrl(String url) {
    if (url.startsWith('http')) return url;
    final base = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';
    final host = base.replaceAll(RegExp(r'/api/?$'), '');
    return '$host$url';
  }

  Future<ProfileBundle> me() async {
    try {
      final res = await _dio.get('/profile/me');
      final data = res.data as Map<String, dynamic>;
      return ProfileBundle(
        profile: data['profile'] == null
            ? null
            : Profile.fromJson(data['profile'] as Map<String, dynamic>),
        children: (data['children'] as List)
            .map((e) => Child.fromJson(e as Map<String, dynamic>))
            .toList(),
        role: data['member']?['role'] as String?,
        roleStatus: data['member']?['role_status'] as String?,
        mobile: data['member']?['mobile'] as String?,
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  /// Partial update — only send the fields you want to change.
  Future<void> update(Map<String, dynamic> fields) async {
    try {
      await _dio.put('/profile/me', data: fields);
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  /// type: member | spouse | child. Returns the stored photo URL.
  Future<String> uploadPhoto(String filePath, {required String type}) async {
    try {
      final form = FormData.fromMap({
        'photo': await MultipartFile.fromFile(filePath),
        'type': type,
      });
      final res = await _dio.post('/profile/photo', data: form);
      return res.data['url'] as String;
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<Child> addChild({required String name, DateTime? dob, String? contact, String? photoUrl}) async {
    try {
      final res = await _dio.post('/profile/children', data: {
        'name': name,
        if (dob != null) 'dob': dob.toIso8601String().substring(0, 10),
        if (contact != null && contact.isNotEmpty) 'contact': contact,
        if (photoUrl != null) 'photo_url': photoUrl,
      });
      return Child.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> deleteChild(int id) async {
    try {
      await _dio.delete('/profile/children/$id');
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<Map<String, String>> requestRole(String role) async {
    try {
      final res = await _dio.patch('/members/role', data: {'role': role});
      return {
        'role': res.data['role'] as String,
        'role_status': res.data['role_status'] as String,
      };
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
