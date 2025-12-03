import '../utils/date_time_utils.dart';

// Attendance model
class AttendanceModel {
  final String id;
  final String workerId;
  final String? siteId;  // Nullable for admin users
  final DateTime date;
  final DateTime? punchInTime;
  final double? punchInLatitude;
  final double? punchInLongitude;
  final String? punchInSelfieUrl;
  final DateTime? punchOutTime;
  final double? punchOutLatitude;
  final double? punchOutLongitude;
  final String? punchOutSelfieUrl;
  final double? totalHours;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceModel({
    required this.id,
    required this.workerId,
    required this.siteId,
    required this.date,
    this.punchInTime,
    this.punchInLatitude,
    this.punchInLongitude,
    this.punchInSelfieUrl,
    this.punchOutTime,
    this.punchOutLatitude,
    this.punchOutLongitude,
    this.punchOutSelfieUrl,
    this.totalHours,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create AttendanceModel from JSON
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      workerId: json['worker_id'] as String,
      siteId: json['site_id'] as String?,  // Nullable for admin users
      date: DateTime.parse(json['date'] as String),
      punchInTime: json['punch_in_time'] != null
          ? DateTime.parse(json['punch_in_time'] as String)
          : null,
      punchInLatitude: json['punch_in_latitude'] != null
          ? double.parse(json['punch_in_latitude'].toString())
          : null,
      punchInLongitude: json['punch_in_longitude'] != null
          ? double.parse(json['punch_in_longitude'].toString())
          : null,
      punchInSelfieUrl: json['punch_in_selfie_url'] as String?,
      punchOutTime: json['punch_out_time'] != null
          ? DateTime.parse(json['punch_out_time'] as String)
          : null,
      punchOutLatitude: json['punch_out_latitude'] != null
          ? double.parse(json['punch_out_latitude'].toString())
          : null,
      punchOutLongitude: json['punch_out_longitude'] != null
          ? double.parse(json['punch_out_longitude'].toString())
          : null,
      punchOutSelfieUrl: json['punch_out_selfie_url'] as String?,
      totalHours: json['total_hours'] != null
          ? double.parse(json['total_hours'].toString())
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert AttendanceModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'worker_id': workerId,
      'site_id': siteId,
      'date': date.toIso8601String(),
      'punch_in_time': punchInTime?.toIso8601String(),
      'punch_in_latitude': punchInLatitude,
      'punch_in_longitude': punchInLongitude,
      'punch_in_selfie_url': punchInSelfieUrl,
      'punch_out_time': punchOutTime?.toIso8601String(),
      'punch_out_latitude': punchOutLatitude,
      'punch_out_longitude': punchOutLongitude,
      'punch_out_selfie_url': punchOutSelfieUrl,
      'total_hours': totalHours,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Check if attendance is complete (both punch in and out)
  bool get isComplete => punchInTime != null && punchOutTime != null;

  // Get formatted date string (in IST)
  String get formattedDate {
    final istDate = DateTimeUtils.convertUtcToIst(date);
    return '${istDate.day}/${istDate.month}/${istDate.year}';
  }

  // Get formatted punch in time (in IST)
  String? get formattedPunchInTime {
    if (punchInTime == null) return null;
    return DateTimeUtils.formatTimeIST(punchInTime);
  }

  // Get formatted punch out time (in IST)
  String? get formattedPunchOutTime {
    if (punchOutTime == null) return null;
    return DateTimeUtils.formatTimeIST(punchOutTime);
  }

  // Get formatted total hours
  String? get formattedTotalHours {
    if (totalHours == null) return null;
    return totalHours!.toStringAsFixed(2);
  }
}
