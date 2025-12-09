import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/announcements_provider.dart';
import '../../screens/login_screen.dart';
import '../../utils/role_utils.dart';
import '../../widgets/admin_controls.dart';
import '../admin/attendance_management_screen.dart' as admin;
import '../coordinator/attendance_management_screen.dart' as coordinator;
import '../admin/create_announcement_screen.dart' as admin_announcement;
import '../coordinator/create_announcement_screen.dart' as coordinator_announcement;
import '../coordinator/my_announcements_screen.dart';
import '../admin/add_worker_to_site_screen.dart' as admin_add_worker;
import '../coordinator/add_worker_to_site_screen.dart' as coordinator_add_worker;
import '../admin/workers_in_my_sites_screen.dart' as admin_workers;
import '../admin/add_site_screen.dart';
import '../admin/add_site_coordinator_screen.dart';
import '../coordinator/workers_in_my_sites_screen.dart' as coordinator_workers;
import '../coordinator/workers_list_screen.dart';
import 'punch_in_screen.dart';
import 'punch_out_screen.dart';
import 'attendance_history_screen.dart';
import 'announcements_screen.dart';
import 'worker_site_assignment_screen.dart';

// Worker dashboard screen
class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshTodayStatus();
      _loadAnnouncements();
    });
  }

  Future<void> _loadAnnouncements() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final announcementsProvider =
        Provider.of<AnnouncementsProvider>(context, listen: false);
    final token = authProvider.token;

    if (token != null) {
      await announcementsProvider.fetchAnnouncements(token: token);
    }
  }

  Future<void> _refreshTodayStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    final token = authProvider.token;

    if (token != null) {
      await attendanceProvider.refreshTodayStatus(token: token);
    }
  }

  void _handlePunchIn() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PunchInScreen(),
      ),
    ).then((_) {
      _refreshTodayStatus();
    });
  }

  void _handlePunchOut() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PunchOutScreen(),
      ),
    ).then((_) {
      _refreshTodayStatus();
    });
  }

  void _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await authProvider.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  String _getUserName() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user?.fullName != null && user!.fullName!.isNotEmpty) {
      return user.fullName!;
    } else if (user?.mobileNumber != null) {
      return user!.mobileNumber;
    }
    return 'Worker';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final userName = _getUserName();
    final userRole = RoleUtils.getUserRole();

    // Get role-specific title
    String dashboardTitle;
    switch (userRole) {
      case 'admin':
        dashboardTitle = 'Admin Dashboard';
        break;
      case 'site_coordinator':
        dashboardTitle = 'Coordinator Dashboard';
        break;
      case 'worker':
      default:
        dashboardTitle = 'Worker Dashboard';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(dashboardTitle),
        elevation: 0,
      ),
      drawer: _buildDrawer(context, authProvider),
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshTodayStatus();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(userName),
              const SizedBox(height: 24),
              
              // Punch In/Out Cards for all roles (Workers, Coordinators, and Admins)
              _buildPunchCards(attendanceProvider),
              const SizedBox(height: 24),
              
              // Admin Controls (only for admin)
              if (userRole == 'admin') ...[
                const AdminControls(),
                const SizedBox(height: 24),
              ],
              
              // Announcements Section (shared by all roles)
              _buildAnnouncementsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String userName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'W',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $userName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPunchCards(AttendanceProvider attendanceProvider) {
    final hasPunchedIn = attendanceProvider.hasPunchedInToday;
    final hasPunchedOut = attendanceProvider.hasPunchedOutToday;
    final punchInTime = _formatTime(attendanceProvider.todayPunchInTime);
    final punchOutTime = _formatTime(attendanceProvider.todayPunchOutTime);

    return Row(
      children: [
        Expanded(
          child: _buildPunchCard(
            title: 'Punch In',
            icon: Icons.login,
            color: Colors.green,
            enabled: !hasPunchedIn,
            time: punchInTime,
            onTap: _handlePunchIn,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPunchCard(
            title: 'Punch Out',
            icon: Icons.logout,
            color: Colors.red,
            enabled: hasPunchedIn && !hasPunchedOut,
            time: punchOutTime,
            onTap: _handlePunchOut,
          ),
        ),
      ],
    );
  }

  String? _formatTime(DateTime? time) {
    if (time == null) return null;
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  Widget _buildPunchCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool enabled,
    String? time,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: enabled ? color : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: enabled ? color.withOpacity(0.1) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: enabled ? color : Colors.grey,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: enabled ? color : Colors.grey,
                ),
              ),
              if (time != null) ...[
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ] else if (!enabled) ...[
                const SizedBox(height: 8),
                Text(
                  'Not available',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementsSection() {
    return Consumer<AnnouncementsProvider>(
      builder: (context, announcementsProvider, _) {
        final announcements = announcementsProvider.announcements
            .where((a) => !a.isExpired)
            .take(2)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Announcements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnnouncementsScreen(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (announcementsProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (announcements.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No announcements',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              ...announcements.map((announcement) {
                return _buildAnnouncementCard(announcement);
              }),
              if (announcementsProvider.announcements.length > 2)
                Card(
                  margin: const EdgeInsets.only(top: 8),
                  child: ListTile(
                    leading: const Icon(Icons.arrow_forward),
                    title: Text(
                      '${announcementsProvider.announcements.length - 2} more announcements',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AnnouncementsScreen(),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAnnouncementCard(announcement) {
    final priorityColor = announcement.priorityColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: priorityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: priorityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.campaign,
            color: priorityColor,
            size: 24,
          ),
        ),
        title: Text(
          announcement.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              announcement.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  announcement.formattedDate,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    announcement.priority.toUpperCase(),
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnnouncementsScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;
    final userName = _getUserName();
    final mobileNumber = user?.mobileNumber ?? 'N/A';
    final userRole = RoleUtils.getUserRole();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 25,  // Reduced from 30
                  backgroundColor: Colors.white,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'W',
                    style: TextStyle(
                      fontSize: 20,  // Reduced from 24
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,  // Reduced from 20
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  mobileNumber,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,  // Reduced from 14
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),  // Reduced vertical padding
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    userRole.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,  // Reduced from 10
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Menu Items
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: true,
            selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          
          // Worker-only menu items
          if (userRole == 'worker') ...[ 
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('My Site Assignment'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkerSiteAssignmentScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('My Attendance'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttendanceHistoryScreen(),
                  ),
                );
              },
            ),
          ],
          
          // Coordinator-only menu items
          if (userRole == 'site_coordinator') ...[
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Attendance Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const coordinator.AttendanceManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Add Worker to Site'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const coordinator_add_worker.AddWorkerToSiteScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.groups),
              title: const Text('Workers in My Sites'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const coordinator_workers.WorkersInMySitesScreen(),
                  ),
                );
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.task_alt),
            //   title: const Text('Approve Tasks'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(content: Text('Approve Tasks - Coming Soon')),
            //     );
            //   },
            // ),
            // ListTile(
            //   leading: const Icon(Icons.campaign),
            //   title: const Text('Create Announcement'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const CreateAnnouncementScreen(),
            //       ),
            //     );
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('Create Announcement'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const coordinator_announcement.CreateAnnouncementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('My Announcements'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyAnnouncementsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Site Attendance'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttendanceHistoryScreen(),
                  ),
                );
              },
            ),
          ],
          
          // Admin-only menu items
          if (userRole == 'admin') ...[
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Attendance Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const admin.AttendanceManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Add Worker to Site'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const admin_add_worker.AddWorkerToSiteScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.groups),
              title: const Text('Workers in Sites'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const admin_workers.WorkersInMySitesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('Create Announcement'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const admin_announcement.CreateAnnouncementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('My Announcements'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyAnnouncementsScreen(),
                  ),
                );
              },
            ),            
            // ListTile(
            //   leading: const Icon(Icons.manage_accounts),
            //   title: const Text('User Management'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(content: Text('User Management - Coming Soon')),
            //     );
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('Add Sites'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddSiteScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Add Site Coordinator'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddSiteCoordinatorScreen(),
                  ),
                );
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.settings),
            //   title: const Text('System Settings'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(content: Text('System Settings - Coming Soon')),
            //     );
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('All Attendance'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttendanceHistoryScreen(),
                  ),
                );
              },
            ),
          ],
          
          // Shared menu items
          ListTile(
            leading: const Icon(Icons.campaign),
            title: const Text('Announcements'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnnouncementsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }
}
