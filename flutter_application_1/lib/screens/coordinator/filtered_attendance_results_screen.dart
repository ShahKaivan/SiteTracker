import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/attendance_model.dart';
import '../../widgets/attendance_card.dart';
import '../../widgets/custom_button.dart';
import '../../services/attendance_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';

/// Filtered Attendance Results Screen for Site Coordinators
/// Displays attendance records based on selected filters with export functionality
class FilteredAttendanceResultsScreen extends StatefulWidget {
  final String siteId;
  final String siteName;
  final String workerId;
  final String workerName;
  final DateTime startDate;
  final DateTime endDate;

  const FilteredAttendanceResultsScreen({
    super.key,
    required this.siteId,
    required this.siteName,
    required this.workerId,
    required this.workerName,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<FilteredAttendanceResultsScreen> createState() =>
      _FilteredAttendanceResultsScreenState();
}

class _FilteredAttendanceResultsScreenState
    extends State<FilteredAttendanceResultsScreen> {
  bool _isLoading = false;
  List<AttendanceModel> _attendanceRecords = [];
  String? _errorMessage;
  
  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _loadFilteredAttendance();
  }

  Future<void> _loadFilteredAttendance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final result = await _attendanceService.getFilteredAttendance(
        token: token,
        siteId: widget.siteId,
        workerId: widget.workerId,
        startDate: widget.startDate,
        endDate: widget.endDate,
      );

      if (result['success'] == true) {
        final recordsData = result['data']['records'] as List<dynamic>;
        final fetchedRecords = recordsData
            .map((record) =>
                AttendanceModel.fromJson(record as Map<String, dynamic>))
            .toList();

        setState(() {
          _attendanceRecords = fetchedRecords;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Results'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Summary Header
          _buildFilterSummary(),

          // Statistics Summary
          if (!_isLoading && _attendanceRecords.isNotEmpty)
            _buildStatisticsSummary(),

          // Attendance List
          Expanded(
            child: _buildAttendanceList(),
          ),

          // Export Button (Fixed at bottom)
          if (!_isLoading && _attendanceRecords.isNotEmpty)
            _buildExportSection(),
        ],
      ),
    );
  }

  Widget _buildFilterSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Applied Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFilterChip(Icons.location_city, 'Site', widget.siteName),
          const SizedBox(height: 6),
          _buildFilterChip(Icons.person, 'Worker', widget.workerName),
          const SizedBox(height: 6),
          _buildFilterChip(
            Icons.date_range,
            'Period',
            '${_formatDate(widget.startDate)} - ${_formatDate(widget.endDate)}',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSummary() {
    final totalDays = _attendanceRecords.length;
    final completeDays =
        _attendanceRecords.where((a) => a.isComplete).length;
    final incompleteDays = totalDays - completeDays;
    final totalHours = _attendanceRecords
        .where((a) => a.totalHours != null)
        .fold(0.0, (sum, a) => sum + a.totalHours!);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Total Days',
                totalDays.toString(),
                Icons.calendar_month,
                AppColors.primary,
              ),
              _buildStatCard(
                'Complete',
                completeDays.toString(),
                Icons.check_circle,
                AppColors.success,
              ),
              _buildStatCard(
                'Incomplete',
                incompleteDays.toString(),
                Icons.access_time,
                AppColors.warning,
              ),
              _buildStatCard(
                'Total Hours',
                totalHours.toStringAsFixed(1),
                Icons.timer,
                AppColors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAttendanceList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading attendance records...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFilteredAttendance,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_attendanceRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No attendance records found',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'for the selected filters',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFilteredAttendance,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _attendanceRecords.length,
        itemBuilder: (context, index) {
          final attendance = _attendanceRecords[index];
          return AttendanceCard(
            attendance: attendance,
            workerName: widget.workerId == 'all' ? 'Worker ${index + 1}' : null,
            onTap: () => _showAttendanceDetails(attendance),
          );
        },
      ),
    );
  }

  Widget _buildExportSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Export to Excel',
              onPressed: _exportToExcel,
              icon: Icons.table_chart,
              backgroundColor: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: 'Export to CSV',
              onPressed: _exportToCSV,
              icon: Icons.file_download,
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToExcel() async {
    try {
      // Request appropriate storage permission based on Android version
      bool hasPermission = false;
      
      if (Platform.isAndroid) {
        // For Android 13+ (API 33+), we need manageExternalStorage
        // For Android 10-12 (API 29-32), we need storage permission
        final storageStatus = await Permission.manageExternalStorage.request();
        
        if (storageStatus.isGranted) {
          hasPermission = true;
        } else if (storageStatus.isPermanentlyDenied) {
          // Open app settings if permanently denied
          if (mounted) {
            final shouldOpenSettings = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Permission Required'),
                content: const Text(
                  'Storage permission is required to export files. Please grant permission in app settings.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );
            
            if (shouldOpenSettings == true) {
              await openAppSettings();
            }
          }
          return;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Storage permission is required to export files'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
      } else {
        hasPermission = true; // iOS doesn't need this permission
      }

      if (!hasPermission) return;

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generating Excel file...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Create Excel file
      var excel = excel_pkg.Excel.createExcel();
      excel_pkg.Sheet sheetObject = excel['Attendance Records'];

      // Add headers
      sheetObject.appendRow([
        excel_pkg.TextCellValue('Date'),
        excel_pkg.TextCellValue('Worker Name'),
        excel_pkg.TextCellValue('Site'),
        excel_pkg.TextCellValue('Punch In Time'),
        excel_pkg.TextCellValue('Punch Out Time'),
        excel_pkg.TextCellValue('Total Hours'),
        excel_pkg.TextCellValue('Status'),
      ]);

      // Add data rows
      for (var record in _attendanceRecords) {
        sheetObject.appendRow([
          excel_pkg.TextCellValue(record.formattedDate),
          excel_pkg.TextCellValue(widget.workerName),
          excel_pkg.TextCellValue(widget.siteName),
          excel_pkg.TextCellValue(record.formattedPunchInTime ?? 'N/A'),
          excel_pkg.TextCellValue(record.formattedPunchOutTime ?? 'Pending'),
          excel_pkg.TextCellValue(
            record.totalHours != null ? '${record.formattedTotalHours} hrs' : 'N/A',
          ),
          excel_pkg.TextCellValue(record.isComplete ? 'Complete' : 'Incomplete'),
        ]);
      }

      // Get directory to save file
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Generate filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'attendance_${widget.siteName.replaceAll(' ', '_')}_$timestamp.xlsx';
      final filePath = '${directory!.path}/$filename';

      // Save file
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel file saved to Downloads folder:\n$filename'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting to Excel: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _exportToCSV() async {
    try {
      // Request appropriate storage permission based on Android version
      bool hasPermission = false;
      
      if (Platform.isAndroid) {
        final storageStatus = await Permission.manageExternalStorage.request();
        
        if (storageStatus.isGranted) {
          hasPermission = true;
        } else if (storageStatus.isPermanentlyDenied) {
          if (mounted) {
            final shouldOpenSettings = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Permission Required'),
                content: const Text(
                  'Storage permission is required to export files. Please grant permission in app settings.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );
            
            if (shouldOpenSettings == true) {
              await openAppSettings();
            }
          }
          return;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Storage permission is required to export files'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
      } else {
        hasPermission = true;
      }

      if (!hasPermission) return;

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generating CSV file...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Prepare CSV data
      List<List<dynamic>> rows = [];

      // Add headers
      rows.add([
        'Date',
        'Worker Name',
        'Site',
        'Punch In Time',
        'Punch Out Time',
        'Total Hours',
        'Status',
      ]);

      // Add data rows
      for (var record in _attendanceRecords) {
        rows.add([
          record.formattedDate,
          widget.workerName,
          widget.siteName,
          record.formattedPunchInTime ?? 'N/A',
          record.formattedPunchOutTime ?? 'Pending',
          record.totalHours != null ? '${record.formattedTotalHours} hrs' : 'N/A',
          record.isComplete ? 'Complete' : 'Incomplete',
        ]);
      }

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(rows);

      // Get directory to save file
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Generate filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'attendance_${widget.siteName.replaceAll(' ', '_')}_$timestamp.csv';
      final filePath = '${directory!.path}/$filename';

      // Save file
      File file = File(filePath);
      await file.writeAsString(csv);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV file saved to Downloads folder:\n$filename'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting to CSV: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showAttendanceDetails(AttendanceModel attendance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Attendance Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Date
                _buildDetailRow(
                    'Date', attendance.formattedDate, Icons.calendar_today),
                const Divider(),
                // Punch In Details
                if (attendance.punchInTime != null) ...[
                  _buildDetailRow(
                    'Punch In Time',
                    attendance.formattedPunchInTime!,
                    Icons.login,
                    Colors.green,
                  ),
                  if (attendance.punchInLatitude != null &&
                      attendance.punchInLongitude != null)
                    _buildDetailRow(
                      'Punch In Location',
                      '${attendance.punchInLatitude!.toStringAsFixed(6)}, ${attendance.punchInLongitude!.toStringAsFixed(6)}',
                      Icons.location_on,
                    ),
                  const Divider(),
                ],
                // Punch Out Details
                if (attendance.punchOutTime != null) ...[
                  _buildDetailRow(
                    'Punch Out Time',
                    attendance.formattedPunchOutTime!,
                    Icons.logout,
                    Colors.red,
                  ),
                  if (attendance.punchOutLatitude != null &&
                      attendance.punchOutLongitude != null)
                    _buildDetailRow(
                      'Punch Out Location',
                      '${attendance.punchOutLatitude!.toStringAsFixed(6)}, ${attendance.punchOutLongitude!.toStringAsFixed(6)}',
                      Icons.location_on,
                    ),
                  const Divider(),
                ],
                // Total Hours
                if (attendance.totalHours != null)
                  _buildDetailRow(
                    'Total Hours',
                    '${attendance.formattedTotalHours} hours',
                    Icons.timer,
                    AppColors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon,
      [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
