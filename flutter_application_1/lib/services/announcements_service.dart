import '../utils/constants.dart';
import '../services/api_service.dart';

// Announcements service
class AnnouncementsService {
  final ApiService _apiService = ApiService();

  /// Get announcements for worker's sites
  /// Returns list of announcements
  Future<Map<String, dynamic>> getMySitesAnnouncements({
    required String token,
  }) async {
    try {
      _apiService.setToken(token);
      final response = await _apiService.get(
        Constants.announcementsMySitesEndpoint,
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        throw Exception(
          response['message'] as String? ?? 'Failed to fetch announcements',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Create new announcement (coordinator only)
  Future<Map<String, dynamic>> createAnnouncement({
    required String token,
    required String siteId,
    required String title,
    required String message,
    required String priority,
    DateTime? expiryDate,
  }) async {
    try {
      _apiService.setToken(token);
      
      final body = {
        'siteId': siteId,
        'title': title,
        'message': message,
        'priority': priority,
        if (expiryDate != null) 'expiryDate': expiryDate.toIso8601String(),
      };

      final response = await _apiService.post(
        Constants.announcementsCreateEndpoint,
        body,
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        throw Exception(
          response['message'] as String? ?? 'Failed to create announcement',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Get announcements created by coordinator (with optional site filter)
  Future<Map<String, dynamic>> getMyAnnouncements({
    required String token,
    String? siteId,
  }) async {
    try {
      _apiService.setToken(token);
      
      String endpoint = Constants.announcementsMyEndpoint;
      if (siteId != null && siteId.isNotEmpty && siteId != 'all') {
        endpoint += '?siteId=$siteId';
      }

      final response = await _apiService.get(endpoint);

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        throw Exception(
          response['message'] as String? ?? 'Failed to fetch announcements',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Deactivate an announcement
  Future<Map<String, dynamic>> deactivateAnnouncement({
    required String token,
    required String announcementId,
  }) async {
    try {
      _apiService.setToken(token);
      
      final url = '${Constants.announcementsDeactivateEndpoint}/$announcementId/deactivate';
      
      final response = await _apiService.patch(url, {});

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        throw Exception(
          response['message'] as String? ?? 'Failed to deactivate announcement',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
