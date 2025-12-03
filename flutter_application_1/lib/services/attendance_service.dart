import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../utils/constants.dart';
import '../services/api_service.dart';

// Attendance service
class AttendanceService {
  final ApiService _apiService = ApiService();

  /// Punch in with selfie and location
  /// Returns attendance record on success
  Future<Map<String, dynamic>> punchIn({
    required String userId,
    String? siteId,  // Made optional for admin users
    required File selfieFile,
    required double latitude,
    required double longitude,
    required String token,
  }) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}${Constants.punchInEndpoint}');
      
      // Create multipart request
      var request = http.MultipartRequest('POST', url);
      
      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      
      // Determine content type based on file extension so the backend
      // receives a correct image MIME type on all platforms.
      final selfiePath = selfieFile.path.toLowerCase();
      MediaType contentType;
      if (selfiePath.endsWith('.png')) {
        contentType = MediaType('image', 'png');
      } else if (selfiePath.endsWith('.webp')) {
        contentType = MediaType('image', 'webp');
      } else {
        // Default to JPEG for .jpg / .jpeg or any other extension produced
        // by the camera plugin.
        contentType = MediaType('image', 'jpeg');
      }

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          selfieFile.path,
          contentType: contentType,
        ),
      );
      
      // Add form fields
      request.fields['user_id'] = userId;
      // Only add site_id if it's not null (for admin users)
      if (siteId != null) {
        request.fields['site_id'] = siteId;
      }
      request.fields['lat'] = latitude.toString();
      request.fields['lng'] = longitude.toString();
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Parse response
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseBody['success'] == true) {
          return {
            'success': true,
            'message': responseBody['message'] as String? ?? 'Punch in successful',
            'data': responseBody['data'],
          };
        } else {
          throw Exception(
            responseBody['message'] as String? ?? 'Punch in failed',
          );
        }
      } else {
        final errorMessage = responseBody['message'] as String? ??
            'An error occurred. Please try again.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Punch out with selfie and location
  /// Returns attendance record on success
  Future<Map<String, dynamic>> punchOut({
    required String userId,
    required File selfieFile,
    required double latitude,
    required double longitude,
    required String token,
  }) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}${Constants.punchOutEndpoint}');
      
      // Create multipart request
      var request = http.MultipartRequest('POST', url);
      
      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      
      // Determine content type based on file extension
      final selfiePath = selfieFile.path.toLowerCase();
      MediaType contentType;
      if (selfiePath.endsWith('.png')) {
        contentType = MediaType('image', 'png');
      } else if (selfiePath.endsWith('.webp')) {
        contentType = MediaType('image', 'webp');
      } else {
        contentType = MediaType('image', 'jpeg');
      }

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          selfieFile.path,
          contentType: contentType,
        ),
      );
      
      // Add form fields
      request.fields['user_id'] = userId;
      request.fields['lat'] = latitude.toString();
      request.fields['lng'] = longitude.toString();
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Parse response
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseBody['success'] == true) {
          return {
            'success': true,
            'message': responseBody['message'] as String? ?? 'Punch out successful',
            'data': responseBody['data'],
          };
        } else {
          throw Exception(
            responseBody['message'] as String? ?? 'Punch out failed',
          );
        }
      } else {
        final errorMessage = responseBody['message'] as String? ??
            'An error occurred. Please try again.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Get attendance records for current user
  Future<Map<String, dynamic>> getAttendanceRecords({
    required String startDate,
    required String endDate,
    required String token,
  }) async {
    try {
      final url = Uri.parse(
        '${Constants.baseUrl}${Constants.attendanceMeEndpoint}?start=$startDate&end=$endDate',
      );
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': responseBody['data'],
        };
      } else {
        final errorMessage = responseBody['message'] as String? ??
            'Failed to fetch attendance records';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Get today's punch status
  Future<Map<String, dynamic>> getTodayStatus({
    required String token,
  }) async {
    try {
      final url = Uri.parse(
        '${Constants.baseUrl}${Constants.attendanceTodayStatusEndpoint}',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': responseBody['data'],
        };
      } else {
        final errorMessage = responseBody['message'] as String? ??
            'Failed to fetch attendance status';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Get filtered attendance records
  /// Returns attendance records based on filters
  Future<Map<String, dynamic>> getFilteredAttendance({
    required String token,
    required String siteId,
    required String workerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      
      final queryParams = 'siteId=$siteId&workerId=$workerId&startDate=$startDateStr&endDate=$endDateStr';
      final url = Uri.parse(
        '${Constants.baseUrl}/attendance/filter?$queryParams',
      );
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': responseBody['data'],
        };
      } else {
        final errorMessage = responseBody['message'] as String? ??
            'Failed to fetch filtered attendance';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
