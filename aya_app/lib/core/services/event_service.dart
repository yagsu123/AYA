import 'package:dio/dio.dart';
import 'api_service.dart';
import 'auth_service.dart' show AuthException;

/// A labarthi (beneficiary) record entered by a member. The contribution
/// [amount] is only present when the viewer is authorised (admin).
class Labarthi {
  const Labarthi({
    required this.id,
    required this.name,
    this.amount,
    this.note,
    this.addedByName,
  });

  final int id;
  final String name;
  final double? amount;
  final String? note;
  final String? addedByName;

  static double? _toAmount(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }

  factory Labarthi.fromJson(Map<String, dynamic> j) => Labarthi(
        id: j['id'] as int,
        name: (j['name'] ?? '') as String,
        amount: _toAmount(j['amount']),
        note: j['note'] as String?,
        addedByName: j['added_by_name'] as String?,
      );
}

/// A member assigned to an event.
class AssignedMember {
  const AssignedMember({
    required this.memberId,
    required this.name,
    this.mobile,
    this.photoUrl,
  });

  final int memberId;
  final String name;
  final String? mobile;
  final String? photoUrl;

  factory AssignedMember.fromJson(Map<String, dynamic> j) => AssignedMember(
        memberId: j['member_id'] as int,
        name: (j['full_name'] ?? '') as String,
        mobile: j['mobile'] as String?,
        photoUrl: j['photo_url'] as String?,
      );
}

/// An event row joined with its vibhag's display data and labarthi summary.
class AppEvent {
  const AppEvent({
    required this.id,
    required this.vibhagType,
    required this.name,
    required this.date,
    this.endDate,
    this.time,
    this.endTime,
    this.venue,
    this.description,
    required this.vibhagName,
    this.vibhagColor,
    this.vibhagIcon,
    this.labarthiCount = 0,
    this.labarthiPreview = const [],
    this.assignedCount = 0,
    this.membersLocked = false,
    this.lockedByName,
    this.lockedAt,
    this.membersUpdatedAt,
  });

  final int id;
  final String vibhagType;
  final String name;
  final DateTime date;
  final DateTime? endDate;
  final String? time; // 'HH:MM' start
  final String? endTime; // 'HH:MM' end
  final String? venue;
  final String? description;
  final String vibhagName;
  final String? vibhagColor;
  final String? vibhagIcon;
  final int labarthiCount;
  final List<String> labarthiPreview; // names only
  final int assignedCount;
  final bool membersLocked;
  final String? lockedByName;
  final DateTime? lockedAt;
  final DateTime? membersUpdatedAt;

  DateTime get lastDay => endDate ?? date;

  bool get isMultiDay => endDate != null && endDate!.difference(date).inDays >= 1;

  int get dayCount => isMultiDay ? endDate!.difference(date).inDays + 1 : 1;

  bool get isPast => lastDay.isBefore(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

  static String? _trimTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split(':');
    return parts.length >= 2 ? '${parts[0]}:${parts[1]}' : raw;
  }

  factory AppEvent.fromJson(Map<String, dynamic> j) => AppEvent(
        id: j['id'] as int,
        vibhagType: j['vibhag_type'] as String,
        name: (j['name'] ?? '') as String,
        date: DateTime.parse(j['date'] as String),
        endDate: j['end_date'] == null
            ? null
            : DateTime.parse(j['end_date'] as String),
        time: _trimTime(j['time'] as String?),
        endTime: _trimTime(j['end_time'] as String?),
        venue: j['venue'] as String?,
        description: j['description'] as String?,
        vibhagName: (j['vibhag_name'] ?? '') as String,
        vibhagColor: j['vibhag_color'] as String?,
        vibhagIcon: j['vibhag_icon'] as String?,
        labarthiCount: (j['labarthi_count'] ?? 0) as int,
        labarthiPreview: ((j['labarthi_preview'] as List?) ?? [])
            .map((e) => e.toString())
            .toList(),
        assignedCount: (j['assigned_count'] ?? 0) as int,
        membersLocked: (j['members_locked'] ?? false) as bool,
        lockedByName: j['locked_by_name'] as String?,
        lockedAt: j['members_locked_at'] == null
            ? null
            : DateTime.tryParse(j['members_locked_at'] as String),
        membersUpdatedAt: j['members_updated_at'] == null
            ? null
            : DateTime.tryParse(j['members_updated_at'] as String),
      );
}

class EventDetail {
  const EventDetail({
    required this.event,
    required this.labarthis,
    required this.assignments,
    required this.canManage,
    required this.canViewAmounts,
    required this.isAdmin,
    required this.canEditMembers,
  });

  final AppEvent event;
  final List<Labarthi> labarthis;
  final List<AssignedMember> assignments;
  final bool canManage;
  final bool canViewAmounts;
  final bool isAdmin;
  final bool canEditMembers;
}

class EventService {
  EventService._();
  static final EventService instance = EventService._();

  Dio get _dio => ApiService.instance.dio;

  Future<List<AppEvent>> list({String? vibhagType, String scope = 'upcoming'}) async {
    try {
      final res = await _dio.get('/events', queryParameters: {
        'scope': scope,
        if (vibhagType != null) 'vibhag_type': vibhagType,
      });
      return (res.data['items'] as List)
          .map((e) => AppEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<EventDetail> detail(int id) async {
    try {
      final res = await _dio.get('/events/$id');
      final data = res.data as Map<String, dynamic>;
      return EventDetail(
        event: AppEvent.fromJson(data['event'] as Map<String, dynamic>),
        labarthis: (data['labarthis'] as List)
            .map((e) => Labarthi.fromJson(e as Map<String, dynamic>))
            .toList(),
        assignments: ((data['assignments'] as List?) ?? [])
            .map((e) => AssignedMember.fromJson(e as Map<String, dynamic>))
            .toList(),
        canManage: (data['can_manage'] ?? false) as bool,
        canViewAmounts: (data['can_view_amounts'] ?? false) as bool,
        isAdmin: (data['is_admin'] ?? false) as bool,
        canEditMembers: (data['can_edit_members'] ?? false) as bool,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<AppEvent> create({
    required String vibhagType,
    required String name,
    required DateTime date,
    DateTime? endDate,
    required String time,
    String? endTime,
    String? venue,
    String? description,
  }) async {
    try {
      final res = await _dio.post('/events', data: {
        'vibhag_type': vibhagType,
        'name': name,
        'date': _isoDate(date),
        if (endDate != null) 'end_date': _isoDate(endDate),
        'time': time,
        if (endTime != null && endTime.isNotEmpty) 'end_time': endTime,
        if (venue != null) 'venue': venue,
        if (description != null) 'description': description,
      });
      return AppEvent.fromJson(res.data['event'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<AppEvent> update(
    int id, {
    required String name,
    required DateTime date,
    DateTime? endDate,
    required String time,
    String? endTime,
    String? venue,
    String? description,
  }) async {
    try {
      final res = await _dio.put('/events/$id', data: {
        'name': name,
        'date': _isoDate(date),
        'end_date': endDate == null ? null : _isoDate(endDate),
        'time': time,
        'end_time': (endTime != null && endTime.isNotEmpty) ? endTime : null,
        'venue': venue,
        'description': description,
      });
      return AppEvent.fromJson(res.data['event'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete('/events/$id');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> addLabarthi(int eventId,
      {required String name, double? amount, String? note}) async {
    try {
      await _dio.post('/events/$eventId/labarthis', data: {
        'name': name,
        if (amount != null) 'amount': amount,
        if (note != null && note.isNotEmpty) 'note': note,
      });
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> removeLabarthi(int eventId, int labarthiId) async {
    try {
      await _dio.delete('/events/$eventId/labarthis/$labarthiId');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<AssignedMember>> setAssignments(int eventId, List<int> memberIds) async {
    try {
      final res = await _dio.put('/events/$eventId/assignments',
          data: {'member_ids': memberIds});
      return (res.data['assignments'] as List)
          .map((e) => AssignedMember.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> setMembersLock(int eventId, bool locked) async {
    try {
      await _dio.patch('/events/$eventId/members-lock', data: {'locked': locked});
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

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
