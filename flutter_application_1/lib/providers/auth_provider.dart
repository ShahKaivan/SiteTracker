import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import '../utils/constants.dart';
import '../utils/role_utils.dart';

// Authentication provider/state management
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final SecureStorageService _secureStorage = SecureStorageService();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _user != null;

  AuthProvider() {
    _loadAuthData();
  }

  /// Load authentication data from shared preferences
  Future<void> _loadAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final secureToken = await _secureStorage.readToken();
      final legacyToken = prefs.getString(Constants.tokenKey);
      final userJsonString = prefs.getString(Constants.userKey);

      final token = secureToken ?? legacyToken;

      if (token != null && userJsonString != null) {
        _token = token;
        _apiService.setToken(token);
        try {
          final userJson = jsonDecode(userJsonString) as Map<String, dynamic>;
          _user = UserModel.fromJson(userJson);

          if (secureToken == null) {
            await _secureStorage.saveAuthSession(
              token: token,
              userId: _user!.id,
              role: RoleUtils.normalizeRole(_user!.role),
              name: _user!.fullName,
            );
          }
          // Initialize role cache
          await RoleUtils.updateCachedRole(_user!.role);
          notifyListeners();
        } catch (e) {
          debugPrint('Error parsing user data: $e');
          // If user data is corrupted, clear it
          await _clearAuthData();
        }
      }
    } catch (e) {
      debugPrint('Error loading auth data: $e');
    }
  }

  /// Save authentication data to shared preferences
  Future<void> _saveAuthData(String token, UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.userKey, jsonEncode(user.toJson()));
      await _secureStorage.saveAuthSession(
        token: token,
        userId: user.id,
        role: RoleUtils.normalizeRole(user.role),
        name: user.fullName,
      );
    } catch (e) {
      debugPrint('Error saving auth data: $e');
    }
  }

  /// Clear authentication data
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.userKey);
      await prefs.remove(Constants.tokenKey);
      await _secureStorage.clearAuthSession();
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
    }
  }

  /// Login with mobile number and password
  Future<bool> login({
    required String mobileNumber,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        mobileNumber: mobileNumber,
        password: password,
      );

      if (result['success'] == true) {
        _token = result['token'] as String;
        _user = result['user'] as UserModel;
        _apiService.setToken(_token);

        // Save to shared preferences
        await _saveAuthData(_token!, _user!);
        
        // Update role cache
        await RoleUtils.updateCachedRole(_user!.role);

        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = result['message'] as String? ?? 'Login failed';
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

  /// Register a new user (for admin)
  Future<bool> register({
    String? fullName,
    required String countryCode,
    required String mobileNumber,
    required String password,
    String? role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        fullName: fullName,
        countryCode: countryCode,
        mobileNumber: mobileNumber,
        password: password,
        role: role,
      );

      _isLoading = false;
      if (result['success'] == true) {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String? ?? 'Registration failed';
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

  /// Logout
  Future<void> logout() async {
    _token = null;
    _user = null;
    _apiService.setToken(null);
    await _clearAuthData();
    // Clear role cache
    await RoleUtils.updateCachedRole(null);
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
