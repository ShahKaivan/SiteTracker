import '../utils/constants.dart';
import '../services/api_service.dart';

// Sites service
class SitesService {
  final ApiService _apiService = ApiService();

  /// Get sites assigned to the authenticated user
  /// Returns list of sites
  Future<Map<String, dynamic>> getMySites({
    required String token,
  }) async {
    try {
      _apiService.setToken(token);
      final response = await _apiService.get(
        Constants.sitesMyEndpoint,
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        throw Exception(
          response['message'] as String? ?? 'Failed to fetch sites',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Get all sites (admin only)
  /// Returns list of all sites
  Future<Map<String, dynamic>> getAllSites({
    required String token,
  }) async {
    try {
      _apiService.setToken(token);
      final response = await _apiService.get(
        '/sites/all',
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        throw Exception(
          response['message'] as String? ?? 'Failed to fetch all sites',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Get workers assigned to a specific site
  /// Returns list of workers for the site
  Future<Map<String, dynamic>> getWorkersBySite({
    required String token,
    required String siteId,
  }) async {
    try {
      _apiService.setToken(token);
      final response = await _apiService.get(
        '/sites/$siteId/workers',
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        throw Exception(
          response['message'] as String? ?? 'Failed to fetch workers',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Assign a worker to a site
  /// Returns the assignment result
  Future<Map<String, dynamic>> assignWorkerToSite({
    required String token,
    required String siteId,
    required String workerId,
  }) async {
    try {
      _apiService.setToken(token);
      final response = await _apiService.post(
        '/sites/$siteId/assign-worker',
        {'workerId': workerId},
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        throw Exception(
          response['message'] as String? ?? 'Failed to assign worker to site',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Remove a worker from a site
  /// Returns the result of the removal
  Future<Map<String, dynamic>> removeWorkerFromSite({
    required String token,
    required String siteId,
    required String workerId,
  }) async {
    try {
      _apiService.setToken(token);
      final response = await _apiService.delete(
        '/sites/$siteId/workers/$workerId',
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        throw Exception(
          response['message'] as String? ?? 'Failed to remove worker from site',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Create a new site (admin only)
  /// Returns the created site data
  Future<Map<String, dynamic>> createSite({
    required String token,
    required Map<String, dynamic> siteData,
  }) async {
    try {
      _apiService.setToken(token);
      final response = await _apiService.post(
        '/sites/create',
        siteData,
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        throw Exception(
          response['message'] as String? ?? 'Failed to create site',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Get sites without a site coordinator (admin only)
  /// Returns list of sites without coordinators
  Future<Map<String, dynamic>> getSitesWithoutCoordinator({
    required String token,
  }) async {
    try {
      _apiService.setToken(token);
      final response = await _apiService.get(
        '/sites/without-coordinator',
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        throw Exception(
          response['message'] as String? ?? 'Failed to fetch sites without coordinator',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Get all site coordinators (admin only)
  /// Returns list of site coordinators
  Future<Map<String, dynamic>> getSiteCoordinators({
    required String token,
  }) async {
    try {
      _apiService.setToken(token);
      final response = await _apiService.get(
        '/users/site-coordinators',
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        throw Exception(
          response['message'] as String? ?? 'Failed to fetch site coordinators',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Assign a site coordinator to a site (admin only)
  /// Returns the assignment result
  Future<Map<String, dynamic>> assignCoordinatorToSite({
    required String token,
    required String siteId,
    required String coordinatorId,
  }) async {
    try {
      _apiService.setToken(token);
      final response = await _apiService.post(
        '/sites/$siteId/assign-coordinator',
        {'coordinatorId': coordinatorId},
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        throw Exception(
          response['message'] as String? ?? 'Failed to assign coordinator to site',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Get current user's site assignment
  /// Returns the current site assignment or null if not assigned
  Future<Map<String, dynamic>> getMyCurrentSiteAssignment({
    required String token,
  }) async {
    try {
      _apiService.setToken(token);
      final response = await _apiService.get(
        '/users/my-site-assignment',
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        throw Exception(
          response['message'] as String? ?? 'Failed to fetch site assignment',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
