import '../services/secure_storage_service.dart';
import 'constants.dart';

class RoleUtils {
  RoleUtils._();

  static final SecureStorageService _secureStorage = SecureStorageService();
  static String? _cachedRole;

  static String normalizeRole(String? role) {
    if (role == null) {
      return 'worker';
    }
    final sanitized = role.trim().toLowerCase();
    return Constants.allowedRoles.contains(sanitized) ? sanitized : 'worker';
  }

  /// Initialize and cache the user's role from storage
  static Future<void> initialize() async {
    final storedRole = await _secureStorage.readRole();
    _cachedRole = normalizeRole(storedRole);
  }

  /// Update the cached role (call this after login/logout)
  static Future<void> updateCachedRole(String? role) async {
    _cachedRole = normalizeRole(role);
  }

  /// Get the current user's role synchronously (returns cached value)
  /// Returns 'worker' if role hasn't been initialized yet
  static String getUserRole() {
    return _cachedRole ?? 'worker';
  }

  static Future<String> _getStoredRole() async {
    final storedRole = await _secureStorage.readRole();
    _cachedRole = normalizeRole(storedRole);
    return _cachedRole!;
  }

  static Future<bool> isWorker() async {
    final role = await _getStoredRole();
    return role == 'worker';
  }

  static Future<bool> isSiteCoordinator() async {
    final role = await _getStoredRole();
    return role == 'site_coordinator';
  }

  static Future<bool> isAdmin() async {
    final role = await _getStoredRole();
    return role == 'admin';
  }
}

