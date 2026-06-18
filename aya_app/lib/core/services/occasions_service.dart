import 'package:dio/dio.dart';
import 'api_service.dart';
import 'auth_service.dart' show AuthException;

class Occasion {
  const Occasion({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.mobile,
    required this.daysUntil,
    required this.years,
    required this.nextOccurrence,
    this.relation = 'member',
    this.via,
  });

  final int id;
  final String name;
  final String? photoUrl;
  final String mobile;
  final int daysUntil;
  final int years;
  final DateTime nextOccurrence;
  final String relation; // member | spouse | child
  final String? via;     // related member's name

  factory Occasion.fromJson(Map<String, dynamic> j) => Occasion(
        id: j['id'] as int,
        name: (j['full_name'] ?? '') as String,
        photoUrl: j['photo_url'] as String?,
        mobile: (j['mobile'] ?? '') as String,
        daysUntil: (j['days_until'] ?? 0) as int,
        years: (j['years'] ?? 0) as int,
        nextOccurrence: DateTime.parse(j['next_occurrence'] as String),
        relation: (j['relation'] ?? 'member') as String,
        via: j['via'] as String?,
      );
}

class OccasionsService {
  OccasionsService._();
  static final OccasionsService instance = OccasionsService._();

  Future<List<Occasion>> fetch({
    required String kind, // 'birthdays' | 'anniversaries'
    required String filter, // 'today' | 'upcoming'
    int days = 30,
  }) async {
    try {
      final res = await ApiService.instance.dio.get(
        '/$kind',
        queryParameters: {'filter': filter, 'days': days},
      );
      return (res.data['items'] as List)
          .map((e) => Occasion.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response == null) {
        throw const AuthException('NETWORK', 'Connection failed. Please try again.');
      }
      throw const AuthException('UNKNOWN', 'Could not load data.');
    }
  }
}
