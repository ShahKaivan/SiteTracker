import '../utils/constants.dart';
import '../services/api_service.dart';

// Users service for unassigned workers
class UsersService {
  final ApiService _apiService = ApiService();

  /// Get unassigned workers (workers not assigned to any site)
  /// Returns list of workers who have no site assignments
  Future<Map<String, dynamic>> getUnassignedWorkers({
    required String token,
  }) async {
    try {
      _apiService.setToken(token);
      final response = await _apiService.get(
        Constants.usersUnassignedEndpoint,
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        throw Exception(
          response['message'] as String? ?? 'Failed to fetch unassigned workers',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
