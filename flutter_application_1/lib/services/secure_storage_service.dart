import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/constants.dart';

/// Wrapper around [FlutterSecureStorage] to persist sensitive auth data.
class SecureStorageService {
  SecureStorageService._internal();
  static final SecureStorageService _instance =
      SecureStorageService._internal();

  factory SecureStorageService() => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveAuthSession({
    required String token,
    required String userId,
    required String role,
    String? name,
  }) async {
    await _storage.write(key: Constants.secureTokenKey, value: token);
    await _storage.write(key: Constants.secureUserIdKey, value: userId);
    await _storage.write(key: Constants.secureRoleKey, value: role);
    if (name != null) {
      await _storage.write(key: Constants.secureUserNameKey, value: name);
    }
  }

  Future<String?> readToken() {
    return _storage.read(key: Constants.secureTokenKey);
  }

  Future<String?> readUserId() {
    return _storage.read(key: Constants.secureUserIdKey);
  }

  Future<String?> readRole() {
    return _storage.read(key: Constants.secureRoleKey);
  }

  Future<String?> readName() {
    return _storage.read(key: Constants.secureUserNameKey);
  }

  Future<void> clearAuthSession() async {
    await Future.wait([
      _storage.delete(key: Constants.secureTokenKey),
      _storage.delete(key: Constants.secureUserIdKey),
      _storage.delete(key: Constants.secureRoleKey),
      _storage.delete(key: Constants.secureUserNameKey),
    ]);
  }
}

