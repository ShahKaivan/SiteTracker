import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/attendance_service.dart';
import '../providers/auth_provider.dart';
import '../models/attendance_model.dart';
import '../utils/date_time_utils.dart';

// Attendance provider/state management
class AttendanceProvider with ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _lastPunchInData;
  Map<String, dynamic>? _lastPunchOutData;
  List<AttendanceModel> _attendanceHistory = [];
  bool _isLoadingHistory = false;
  String? _historyErrorMessage;
  bool _hasPunchedInToday = false;
  bool _hasPunchedOutToday = false;
  DateTime? _todayPunchInTime;
  DateTime? _todayPunchOutTime;
  bool _isLoadingTodayStatus = false;
  String? _todayStatusError;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get lastPunchInData => _lastPunchInData;
  Map<String, dynamic>? get lastPunchOutData => _lastPunchOutData;
  List<AttendanceModel> get attendanceHistory => _attendanceHistory;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get historyErrorMessage => _historyErrorMessage;
  bool get hasPunchedInToday => _hasPunchedInToday;
  bool get hasPunchedOutToday => _hasPunchedOutToday;
  DateTime? get todayPunchInTime => _todayPunchInTime;
  DateTime? get todayPunchOutTime => _todayPunchOutTime;
  bool get isLoadingTodayStatus => _isLoadingTodayStatus;
  String? get todayStatusError => _todayStatusError;

  /// Punch in
  Future<bool> punchIn({
    required String userId,
    String? siteId,  // Made optional for admin users
    required File selfieFile,
    required double latitude,
    required double longitude,
    required String token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _attendanceService.punchIn(
        userId: userId,
        siteId: siteId,
        selfieFile: selfieFile,
        latitude: latitude,
        longitude: longitude,
        token: token,
      );

      if (result['success'] == true) {
        _lastPunchInData = result['data'];
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        await refreshTodayStatus(token: token);
        return true;
      } else {
        _isLoading = false;
        _errorMessage = result['message'] as String? ?? 'Punch in failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Punch out
  Future<bool> punchOut({
    required String userId,
    required File selfieFile,
    required double latitude,
    required double longitude,
    required String token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _attendanceService.punchOut(
        userId: userId,
        selfieFile: selfieFile,
        latitude: latitude,
        longitude: longitude,
        token: token,
      );

      if (result['success'] == true) {
        _lastPunchOutData = result['data'];
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        await refreshTodayStatus(token: token);
        return true;
      } else {
        _isLoading = false;
        _errorMessage = result['message'] as String? ?? 'Punch out failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Refresh today's punch status
  Future<void> refreshTodayStatus({required String token}) async {
    _isLoadingTodayStatus = true;
    _todayStatusError = null;
    notifyListeners();

    try {
      final result = await _attendanceService.getTodayStatus(token: token);
      final data = result['data'] as Map<String, dynamic>? ?? {};

      _hasPunchedInToday = data['has_punched_in'] == true;
      _hasPunchedOutToday = data['has_punched_out'] == true;

      final punchIn = data['punch_in_time'] as String?;
      final punchOut = data['punch_out_time'] as String?;

      _todayPunchInTime =
          punchIn != null ? DateTimeUtils.convertUtcToIst(DateTime.parse(punchIn)) : null;
      _todayPunchOutTime =
          punchOut != null ? DateTimeUtils.convertUtcToIst(DateTime.parse(punchOut)) : null;
    } catch (e) {
      _todayStatusError = e.toString();
    } finally {
      _isLoadingTodayStatus = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset punch data
  void resetPunchData() {
    _lastPunchInData = null;
    _lastPunchOutData = null;
    _errorMessage = null;
    _hasPunchedInToday = false;
    _hasPunchedOutToday = false;
    _todayPunchInTime = null;
    _todayPunchOutTime = null;
    _todayStatusError = null;
    notifyListeners();
  }

  /// Fetch attendance history
  Future<bool> fetchAttendanceHistory({
    required DateTime startDate,
    required DateTime endDate,
    required String token,
  }) async {
    _isLoadingHistory = true;
    _historyErrorMessage = null;
    notifyListeners();

    try {
      // Format dates as YYYY-MM-DD
      final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

      final result = await _attendanceService.getAttendanceRecords(
        startDate: startDateStr,
        endDate: endDateStr,
        token: token,
      );

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>?;
        final records = data?['records'] as List<dynamic>? ?? [];

        _attendanceHistory = records
            .map((record) => AttendanceModel.fromJson(record as Map<String, dynamic>))
            .toList();

        _isLoadingHistory = false;
        _historyErrorMessage = null;
        notifyListeners();
        return true;
      } else {
        _isLoadingHistory = false;
        _historyErrorMessage = 'Failed to fetch attendance history';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoadingHistory = false;
      _historyErrorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear history error message
  void clearHistoryError() {
    _historyErrorMessage = null;
    notifyListeners();
  }
}
