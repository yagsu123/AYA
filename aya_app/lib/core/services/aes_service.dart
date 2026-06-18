import 'package:dio/dio.dart';
import 'api_service.dart';
import 'auth_service.dart' show AuthException;

class AesContent {
  const AesContent({
    this.whatIsAes,
    this.history,
    this.objectives,
    this.donationContact,
    this.progressCurrent = 0,
    this.progressTarget = 0,
  });

  final String? whatIsAes;
  final String? history;
  final String? objectives;
  final String? donationContact;
  final double progressCurrent;
  final double progressTarget;

  double get progressPct =>
      progressTarget <= 0 ? 0 : (progressCurrent / progressTarget).clamp(0, 1).toDouble();

  static double _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory AesContent.fromJson(Map<String, dynamic> j) => AesContent(
        whatIsAes: j['what_is_aes'] as String?,
        history: j['history'] as String?,
        objectives: j['objectives'] as String?,
        donationContact: j['donation_contact'] as String?,
        progressCurrent: _toNum(j['progress_current']),
        progressTarget: _toNum(j['progress_target']),
      );
}

class AesData {
  const AesData({required this.content, required this.isAdmin});
  final AesContent content;
  final bool isAdmin;
}

class AesService {
  AesService._();
  static final AesService instance = AesService._();

  Dio get _dio => ApiService.instance.dio;

  Future<AesData> get() async {
    try {
      final res = await _dio.get('/aes');
      final data = res.data as Map<String, dynamic>;
      final c = data['content'];
      return AesData(
        content: c == null
            ? const AesContent()
            : AesContent.fromJson(c as Map<String, dynamic>),
        isAdmin: (data['is_admin'] ?? false) as bool,
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<AesContent> update({
    String? whatIsAes,
    String? history,
    String? objectives,
    String? donationContact,
    double? progressCurrent,
    double? progressTarget,
  }) async {
    try {
      final res = await _dio.put('/aes', data: {
        if (whatIsAes != null) 'what_is_aes': whatIsAes,
        if (history != null) 'history': history,
        if (objectives != null) 'objectives': objectives,
        if (donationContact != null && donationContact.isNotEmpty)
          'donation_contact': donationContact,
        if (progressCurrent != null) 'progress_current': progressCurrent,
        if (progressTarget != null) 'progress_target': progressTarget,
      });
      return AesContent.fromJson(res.data['content'] as Map<String, dynamic>);
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
