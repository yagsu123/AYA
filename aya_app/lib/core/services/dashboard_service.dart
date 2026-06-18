import 'package:dio/dio.dart';
import 'api_service.dart';
import 'auth_service.dart' show AuthException;

class DashboardMember {
  const DashboardMember({this.fullName, this.photoUrl, this.mobile,
      required this.role, required this.roleStatus});
  final String? fullName;
  final String? photoUrl;
  final String? mobile;
  final String role;
  final String roleStatus;

  factory DashboardMember.fromJson(Map<String, dynamic> j) => DashboardMember(
        fullName: j['full_name'] as String?,
        photoUrl: j['photo_url'] as String?,
        mobile: j['mobile'] as String?,
        role: (j['role'] ?? 'member') as String,
        roleStatus: (j['role_status'] ?? 'approved') as String,
      );
}

class CelebrationEntry {
  const CelebrationEntry({required this.id, required this.name,
      this.photoUrl, required this.mobile, this.date,
      this.relation = 'member', this.via});
  final int id;
  final String name;
  final String? photoUrl;
  final String mobile;
  final DateTime? date; // dob or anniversary_date
  final String relation;
  final String? via;

  int? get years {
    if (date == null) return null;
    return DateTime.now().year - date!.year;
  }

  factory CelebrationEntry.fromJson(Map<String, dynamic> j, String dateKey) =>
      CelebrationEntry(
        id: j['id'] as int,
        name: (j['full_name'] ?? '') as String,
        photoUrl: j['photo_url'] as String?,
        mobile: (j['mobile'] ?? '') as String,
        date: j[dateKey] == null ? null : DateTime.tryParse(j[dateKey] as String),
        relation: (j['relation'] ?? 'member') as String,
        via: j['via'] as String?,
      );
}

class NextEvent {
  const NextEvent({required this.id, required this.vibhagType,
      required this.name, required this.date, this.time, this.venue});
  final int id;
  final String vibhagType;
  final String name;
  final DateTime date;
  final String? time;
  final String? venue;

  factory NextEvent.fromJson(Map<String, dynamic> j) => NextEvent(
        id: j['id'] as int,
        vibhagType: (j['vibhag_type'] ?? '') as String,
        name: (j['name'] ?? '') as String,
        date: DateTime.parse(j['date'] as String),
        time: j['time'] as String?,
        venue: j['venue'] as String?,
      );
}

class Ad {
  const Ad({required this.id, this.title, required this.imageUrl, this.linkUrl});
  final int id;
  final String? title;
  final String imageUrl;
  final String? linkUrl;

  factory Ad.fromJson(Map<String, dynamic> j) => Ad(
        id: j['id'] as int,
        title: j['title'] as String?,
        imageUrl: j['image_url'] as String,
        linkUrl: j['link_url'] as String?,
      );
}

class DashboardData {
  const DashboardData({
    required this.member,
    required this.todayBirthdays,
    required this.todayAnniversaries,
    this.nextEvent,
    required this.profileCompletePct,
    this.membersCount = 0,
    required this.ads,
  });

  final DashboardMember member;
  final List<CelebrationEntry> todayBirthdays;
  final List<CelebrationEntry> todayAnniversaries;
  final NextEvent? nextEvent;
  final int profileCompletePct;
  final int membersCount;
  final List<Ad> ads;

  factory DashboardData.fromJson(Map<String, dynamic> j) => DashboardData(
        member: DashboardMember.fromJson(j['member'] as Map<String, dynamic>),
        todayBirthdays: (j['todayBirthdays'] as List)
            .map((e) => CelebrationEntry.fromJson(e as Map<String, dynamic>, 'dob'))
            .toList(),
        todayAnniversaries: (j['todayAnniversaries'] as List)
            .map((e) =>
                CelebrationEntry.fromJson(e as Map<String, dynamic>, 'anniversary_date'))
            .toList(),
        nextEvent: j['nextEvent'] == null
            ? null
            : NextEvent.fromJson(j['nextEvent'] as Map<String, dynamic>),
        profileCompletePct: (j['profileCompletePct'] ?? 0) as int,
        membersCount: (j['membersCount'] ?? 0) as int,
        ads: (j['ads'] as List)
            .map((e) => Ad.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class DashboardService {
  DashboardService._();
  static final DashboardService instance = DashboardService._();

  Future<DashboardData> fetch() async {
    try {
      final res = await ApiService.instance.dio.get('/dashboard');
      return DashboardData.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response == null) {
        throw const AuthException('NETWORK', 'Connection failed. Please try again.');
      }
      throw const AuthException('UNKNOWN', 'Could not load dashboard.');
    }
  }
}
