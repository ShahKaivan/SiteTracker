// App constants
class Constants {
  // API Base URL - Update this with your backend URL
  static const String baseUrl = 'http://giveyourip:3000';
  // For Android emulator, use: 'http://10.0.2.2:3000'
  // For iOS simulator, use: 'http://localhost:3000'
  // For physical device, use your computer's IP: 'http://192.168.x.x:3000'

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String getMeEndpoint = '/auth/me';
  static const String punchInEndpoint = '/attendance/punch-in';
  static const String punchOutEndpoint = '/attendance/punch-out';
  static const String attendanceMeEndpoint = '/attendance/me';
  static const String attendanceTodayStatusEndpoint =
      '/attendance/status/today';
  static const String announcementsMySitesEndpoint = '/announcements/my-sites';
  static const String announcementsCreateEndpoint = '/announcements/create';
  static const String announcementsMyEndpoint = '/announcements/my';
  static const String announcementsDeactivateEndpoint = '/announcements'; // + /:id/deactivate
  static const String sitesMyEndpoint = '/sites/my';
  static const String attendanceFilterEndpoint = '/attendance/filter';
  static const String usersUnassignedEndpoint = '/users/unassigned';
  // siteAssignWorkerEndpoint will be used as '/sites/:id/assign-worker'

  // Temporary default site ID (must exist in backend DB)
  static const String defaultSiteId = '11111111-1111-1111-1111-111111111111';

  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String secureTokenKey = 'secure_auth_token';
  static const String secureUserIdKey = 'secure_user_id';
  static const String secureRoleKey = 'secure_user_role';
  static const String secureUserNameKey = 'secure_user_name';

  // Default Country Code
  static const String defaultCountryCode = '+91';

  static const List<String> allowedRoles = [
    'worker',
    'site_coordinator',
    'admin',
  ];
}
