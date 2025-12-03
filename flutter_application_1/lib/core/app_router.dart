import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/worker/worker_dashboard.dart';
import '../utils/role_utils.dart';

/// Application router configuration with protected routes
class AppRouter {
  static const String login = '/login';
  static const String workerDashboard = '/worker-dashboard';
  static const String coordinatorDashboard = '/coordinator-dashboard';
  static const String adminDashboard = '/admin-dashboard';

  /// Get dashboard path based on user role
  static String _getRoleDashboardPath(String role) {
    switch (role) {
      case 'admin':
        return adminDashboard;
      case 'site_coordinator':
        return coordinatorDashboard;
      case 'worker':
      default:
        return workerDashboard;
    }
  }

  /// Check if user has permission to access a route
  static bool _hasRolePermission(String location, String role) {
    // Admin can access all routes
    if (role == 'admin') {
      return location == adminDashboard ||
          location == coordinatorDashboard ||
          location == workerDashboard;
    }

    // Site coordinator can access coordinator and worker routes
    if (role == 'site_coordinator') {
      return location == coordinatorDashboard || location == workerDashboard;
    }

    // Worker can only access worker routes
    if (role == 'worker') {
      return location == workerDashboard;
    }

    return false;
  }

  /// Create GoRouter instance
  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: login,
      debugLogDiagnostics: true,
      redirect: (BuildContext context, GoRouterState state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isAuthenticated = authProvider.isAuthenticated;
        final userRole = RoleUtils.getUserRole();
        final location = state.uri.path;

        // Not authenticated -> redirect to login
        if (!isAuthenticated && location != login) {
          return login;
        }

        // Authenticated but on login -> redirect to role dashboard
        if (isAuthenticated && location == login) {
          return _getRoleDashboardPath(userRole);
        }

        // Check if user has permission for this route
        if (isAuthenticated && !_hasRolePermission(location, userRole)) {
          return _getRoleDashboardPath(userRole);
        }

        return null; // No redirect needed
      },
      routes: [
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: workerDashboard,
          builder: (context, state) => const WorkerDashboard(),
        ),
        GoRoute(
          path: coordinatorDashboard,
          builder: (context, state) => const WorkerDashboard(),
        ),
        GoRoute(
          path: adminDashboard,
          builder: (context, state) => const WorkerDashboard(),
        ),
      ],
    );
  }
}
