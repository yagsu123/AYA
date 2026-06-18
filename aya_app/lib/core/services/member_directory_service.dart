import 'package:dio/dio.dart';
import 'api_service.dart';
import 'auth_service.dart' show AuthException;

/// A selectable active member (used by assignment pickers).
class DirectoryMember {
  const DirectoryMember({
    required this.id,
    required this.name,
    this.mobile,
    this.photoUrl,
  });

  final int id;
  final String name;
  final String? mobile;
  final String? photoUrl;

  factory DirectoryMember.fromJson(Map<String, dynamic> j) => DirectoryMember(
        id: j['id'] as int,
        name: (j['full_name'] ?? '') as String,
        mobile: j['mobile'] as String?,
        photoUrl: j['photo_url'] as String?,
      );
}

class MemberDirectoryService {
  MemberDirectoryService._();
  static final MemberDirectoryService instance = MemberDirectoryService._();

  Future<List<DirectoryMember>> activeMembers() async {
    try {
      final res = await ApiService.instance.dio.get('/members');
      return (res.data['items'] as List)
          .map((e) => DirectoryMember.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response == null) {
        throw const AuthException('NETWORK', 'Connection failed. Please try again.');
      }
      throw const AuthException('UNKNOWN', 'Could not load members.');
    }
  }
}
