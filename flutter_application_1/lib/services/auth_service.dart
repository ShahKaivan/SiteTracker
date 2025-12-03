import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

// Authentication service
class AuthService {
  final ApiService _apiService = ApiService();

  /// Login with mobile number and password
  /// Returns token and user data
  Future<Map<String, dynamic>> login({
    required String mobileNumber,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(Constants.loginEndpoint, {
        'mobile_number': mobileNumber,
        'password': password,
      });

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final userJson = data['user'] as Map<String, dynamic>;

        final user = UserModel.fromJson(userJson);

        return {
          'success': true,
          'message': response['message'] as String? ?? 'Login successful',
          'token': token,
          'user': user,
        };
      } else {
        throw Exception(response['message'] as String? ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Register a new user (for admin)
  Future<Map<String, dynamic>> register({
    String? fullName,
    required String countryCode,
    required String mobileNumber,
    required String password,
    String? role,
    String? profileImagePath,
  }) async {
    try {
      Map<String, dynamic> response;
      
      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        // Use multipart request for file upload
        final fields = <String, String>{
          'country_code': countryCode,
          'mobile_number': mobileNumber,
          'password': password,
        };
        
        if (fullName != null && fullName.isNotEmpty) {
          fields['full_name'] = fullName;
        }
        
        if (role != null && role.isNotEmpty) {
          fields['role'] = role;
        }
        
        final files = <String, String>{
          'profile_image': profileImagePath,
        };
        
        response = await _apiService.postMultipart(
          Constants.registerEndpoint,
          fields,
          files,
        );
      } else {
        // Use regular JSON request
        final body = <String, dynamic>{
          'country_code': countryCode,
          'mobile_number': mobileNumber,
          'password': password,
        };
        
        if (fullName != null) {
          body['full_name'] = fullName;
        }
        
        if (role != null) {
          body['role'] = role;
        }
        
        response = await _apiService.post(Constants.registerEndpoint, body);
      }

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final userJson = data['user'] as Map<String, dynamic>;

        final user = UserModel.fromJson(userJson);

        return {
          'success': true,
          'message':
              response['message'] as String? ?? 'Registration successful',
          'user': user,
        };
      } else {
        throw Exception(
          response['message'] as String? ?? 'Registration failed',
        );
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Get current user information
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiService.get(Constants.getMeEndpoint);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final userJson = data['user'] as Map<String, dynamic>;
        return UserModel.fromJson(userJson);
      } else {
        throw Exception('Failed to get user information');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
