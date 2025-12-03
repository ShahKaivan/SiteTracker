import 'package:flutter/material.dart';
import '../screens/admin/add_site_screen.dart';
import '../screens/admin/create_announcement_screen.dart';
import '../screens/admin/attendance_management_screen.dart';
import '../screens/admin/workers_in_my_sites_screen.dart';

/// Admin-specific controls widget
class AdminControls extends StatelessWidget {
  const AdminControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Admin Controls',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildControlsGrid(context),
      ],
    );
  }

  Widget _buildControlsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.05,  // Increased height to prevent overflow
      children: [
        _buildControlCard(
          context: context,
          icon: Icons.add_location_alt,
          title: 'Add Sites',
          color: Colors.teal,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddSiteScreen(),
              ),
            );
          },
        ),
        _buildControlCard(
          context: context,
          icon: Icons.campaign,
          title: 'Create Announcement',
          color: Colors.deepOrange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateAnnouncementScreen(),
              ),
            );
          },
        ),
        _buildControlCard(
          context: context,
          icon: Icons.fact_check,
          title: 'Attendance Management',
          color: Colors.indigo,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AttendanceManagementScreen(),
              ),
            );
          },
        ),
        _buildControlCard(
          context: context,
          icon: Icons.people,
          title: 'Workers in Sites',
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WorkersInMySitesScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildControlCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
