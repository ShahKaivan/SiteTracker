import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../services/sites_service.dart';
import 'add_worker_to_site_screen.dart';
import 'attendance_management_screen.dart';

/// Workers in My Sites Screen for Site Coordinators
/// Displays all workers assigned to coordinator's sites with filtering
class WorkersInMySitesScreen extends StatefulWidget {
  const WorkersInMySitesScreen({super.key});

  @override
  State<WorkersInMySitesScreen> createState() => _WorkersInMySitesScreenState();
}

class _WorkersInMySitesScreenState extends State<WorkersInMySitesScreen> {
  bool _isLoading = false;
  bool _isLoadingSites = false;
  String? _selectedSiteId;

  List<Map<String, dynamic>> _sites = [];
  List<Map<String, dynamic>> _currentWorkers = [];
  
  final SitesService _sitesService = SitesService();

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  Future<void> _loadSites() async {
    setState(() {
      _isLoadingSites = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final result = await _sitesService.getMySites(token: token);

      if (result['success'] == true) {
        final sitesData = result['data']['sites'] as List<dynamic>;
        final fetchedSites = sitesData.map((site) => <String, dynamic>{
          'id': site['id'] as String,
          'name': site['name'] as String,
          'code': site['code'] as String? ?? '',
        }).toList();

        setState(() {
          _sites = fetchedSites;
          _isLoadingSites = false;
          // Auto-select first site
          if (_sites.isNotEmpty && _selectedSiteId == null) {
            _selectedSiteId = _sites.first['id'] as String;
            _loadWorkers();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSites = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sites: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadWorkers() async {
    if (_selectedSiteId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final result = await _sitesService.getWorkersBySite(
        token: token,
        siteId: _selectedSiteId!,
      );

      if (result['success'] == true) {
        final workersData = result['data']['workers'] as List<dynamic>;
        final fetchedWorkers = workersData.map((worker) => {
          'id': worker['id'] as String,
          'name': worker['name'] as String,
          'mobile': worker['mobile_number'] as String? ?? '',
          'role': worker['role'] as String? ?? 'worker',
        }).toList();

        setState(() {
          _currentWorkers = fetchedWorkers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading workers: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workers in My Sites'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWorkers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Site Selection
          _buildSiteSelector(),

          // Workers List
          Expanded(child: _buildWorkersList()),

          // Add Worker Button
          _buildAddWorkerButton(),
        ],
      ),
    );
  }

  Widget _buildSiteSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_city, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Select Site',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingSites)
            const LinearProgressIndicator()
          else
            DropdownButtonFormField<String>(
              value: _selectedSiteId,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              isExpanded: true,
              items: _sites.map((site) {
                return DropdownMenuItem<String>(
                  value: site['id'] as String,
                  child: Text(
                    site['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSiteId = value;
                });
                _loadWorkers();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWorkersList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height:16),
            Text('Loading workers...'),
          ],
        ),
      );
    }

    if (_currentWorkers.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline,
        title: 'No workers found',
        message: 'No workers are assigned to this site yet.',
        actionLabel: 'Add Worker',
        onAction: _navigateToAddWorker,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWorkers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _currentWorkers.length,
        itemBuilder: (context, index) {
          final worker = _currentWorkers[index];
          return _buildWorkerCard(worker);
        },
      ),
    );
  }

  Widget _buildWorkerCard(Map<String, dynamic> worker) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Profile Placeholder
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                _getInitials(worker['name'] as String),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Worker Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker['name'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        worker['mobile'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'WORKER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Action Icon
            IconButton(
              icon: const Icon(Icons.more_vert),
              color: AppColors.textSecondary,
              onPressed: () => _showWorkerActions(worker),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddWorkerButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: CustomButton(
        text: 'Add Worker to Site',
        onPressed: _navigateToAddWorker,
        icon: Icons.person_add,
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1))
        .toUpperCase();
  }

  void _navigateToAddWorker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddWorkerToSiteScreen(),
      ),
    ).then((_) {
      _loadWorkers();
    });
  }

  void _showWorkerActions(Map<String, dynamic> worker) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Worker name
            Text(
              worker['name'] as String,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Actions
            ListTile(
              leading: const Icon(Icons.visibility, color: AppColors.primary),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _showWorkerDetails(worker);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: AppColors.info),
              title: const Text('View Attendance'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAttendance(worker);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: AppColors.error),
              title: const Text('Remove from Site'),
              onTap: () {
                Navigator.pop(context);
                _confirmRemoveWorker(worker);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkerDetails(Map<String, dynamic> worker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                _getInitials(worker['name'] as String),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                worker['name'] as String,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.phone, 'Mobile', worker['mobile'] as String),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.badge, 'Role', (worker['role'] as String).toUpperCase()),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.location_city, 'Site', _getSiteName()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getSiteName() {
    if (_selectedSiteId == null) return 'Unknown';
    final site = _sites.firstWhere(
      (s) => s['id'] == _selectedSiteId,
      orElse: () => <String, dynamic>{'name': 'Unknown'},
    );
    return site['name'] as String;
  }

  void _navigateToAttendance(Map<String, dynamic> worker) {
    // Navigate to attendance management with worker pre-selected
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceManagementScreen(
          preSelectedSiteId: _selectedSiteId,
          preSelectedSiteName: _getSiteName(),
          preSelectedWorkerId: worker['id'] as String,
          preSelectedWorkerName: worker['name'] as String,
        ),
      ),
    );
  }

  Future<void> _confirmRemoveWorker(Map<String, dynamic> worker) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Remove Worker?'),
          ],
        ),
        content: Text(
          'Are you sure you want to remove ${worker['name']} from this site?\n\nThis will unassign them but not delete their account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _removeWorkerFromSite(worker);
    }
  }

  Future<void> _removeWorkerFromSite(Map<String, dynamic> worker) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final result = await _sitesService.removeWorkerFromSite(
        token: token,
        siteId: _selectedSiteId!,
        workerId: worker['id'] as String,
      );

      if (result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${worker['name']} removed from site'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadWorkers(); // Reload the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
