import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../services/sites_service.dart';
import '../../services/users_service.dart';
import '../../utils/role_utils.dart';
// import 'worker_list_screen.dart';
import 'workers_in_my_sites_screen.dart';
/// Add Worker to Site Screen for Site Coordinators
/// Allows coordinators to assign unassigned workers to their sites
class AddWorkerToSiteScreen extends StatefulWidget {
  const AddWorkerToSiteScreen({super.key});

  @override
  State<AddWorkerToSiteScreen> createState() => _AddWorkerToSiteScreenState();
}

class _AddWorkerToSiteScreenState extends State<AddWorkerToSiteScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedSiteId;
  String? _selectedWorkerId;
  bool _isLoading = false;
  bool _isLoadingSites = false;
  bool _isLoadingWorkers = false;
  bool _hasCoordinator = false;
  bool _isCheckingCoordinator = false;

  List<Map<String, dynamic>> _assignedSites = [];
  List<Map<String, dynamic>> _unassignedWorkers = [];
  
  final SitesService _sitesService = SitesService();
  final UsersService _usersService = UsersService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadAssignedSites();
    await _loadUnassignedWorkers();
  }

  Future<void> _loadAssignedSites() async {
    setState(() {
      _isLoadingSites = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final userRole = RoleUtils.getUserRole();
      final result = userRole == 'admin'
          ? await _sitesService.getAllSites(token: token)
          : await _sitesService.getMySites(token: token);

      if (result['success'] == true) {
        final sitesData = result['data']['sites'] as List<dynamic>;
        final fetchedSites = sitesData.map((site) => {
          'id': site['id'] as String,
          'name': site['name'] as String,
          'code': site['code'] as String? ?? '',
        }).toList();

        setState(() {
          _assignedSites = fetchedSites;
          _isLoadingSites = false;
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

  Future<void> _loadUnassignedWorkers() async {
    setState(() {
      _isLoadingWorkers = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final result = await _usersService.getUnassignedWorkers(token: token);

      if (result['success'] == true) {
        final workersData = result['data']['workers'] as List<dynamic>;
        final fetchedWorkers = workersData.map((worker) => {
          'id': worker['id'] as String,
          'name': worker['full_name'] as String,
          'mobile': worker['mobile_number'] as String? ?? '',
        }).toList();

        setState(() {
          _unassignedWorkers = fetchedWorkers;
          _isLoadingWorkers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWorkers = false;
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

  Future<void> _checkSiteCoordinator(String siteId) async {
    setState(() {
      _isCheckingCoordinator = true;
      _hasCoordinator = false;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) return;

      final result = await _sitesService.getWorkersBySite(token: token, siteId: siteId);

      if (result['success'] == true) {
        final users = result['data']['workers'] as List<dynamic>;
        // Check if any user has role 'site_coordinator'
        final hasCoordinator = users.any((user) => user['role'] == 'site_coordinator');

        setState(() {
          _hasCoordinator = hasCoordinator;
          _isCheckingCoordinator = false;
        });
      }
    } catch (e) {
      setState(() {
        _isCheckingCoordinator = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking site coordinator: ${e.toString()}'),
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
        title: const Text('Add Worker to Site'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              _buildHeaderCard(),
              const SizedBox(height: 24),

              // Site Selection
              _buildSectionHeader('Select Site', Icons.location_city),
              const SizedBox(height: 12),
              _buildSiteDropdown(),
              if (_selectedSiteId != null && !_isCheckingCoordinator && !_hasCoordinator)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This site has no coordinator assigned. You cannot add workers.',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Worker Selection
              _buildSectionHeader('Select Worker', Icons.person),
              const SizedBox(height: 12),
              _buildWorkerDropdown(),
              const SizedBox(height: 32),

              // Assign Button
              CustomButton(
                text: 'Assign Worker to Site',
                onPressed: (_isLoading || (_selectedSiteId != null && !_hasCoordinator)) 
                    ? () {} 
                    : _assignWorker,
                icon: Icons.person_add,
                isLoading: _isLoading,
                backgroundColor: (_selectedSiteId != null && !_hasCoordinator)
                    ? Colors.grey
                    : AppColors.primary,
              ),

              const SizedBox(height: 16),

              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info, color: AppColors.info, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Worker Assignment',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.info,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '• Only workers not assigned to any site are shown\\n'
                            '• Worker will be assigned to the selected site\\n'
                            '• Worker can start punch-in/out at the assigned site',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (_unassignedWorkers.isEmpty && !_isLoadingWorkers)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: AppColors.warning, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No unassigned workers available. All workers are already assigned to sites.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_add,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assign Worker to Site',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Assign unassigned workers to your sites',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSiteDropdown() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: DropdownButtonFormField<String>(
          value: _selectedSiteId,
          isDense: true,
          decoration: InputDecoration(
            labelText: 'Select Site',
            prefixIcon: const Icon(Icons.location_city, color: AppColors.primary, size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
          ),
          hint: const Text('Choose a site'),
          isExpanded: true,
          items: _isLoadingSites
              ? []
              : _assignedSites.map((site) {
                  return DropdownMenuItem<String>(
                    value: site['id'] as String,
                    child: Text(
                      '${site['name']} (${site['code']})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
          onChanged: _isLoadingSites
              ? null
              : (value) {
                  setState(() {
                    _selectedSiteId = value;
                    if (value != null) {
                      _checkSiteCoordinator(value);
                    }
                  });
                },
          validator: (value) {
            if (value == null) {
              return 'Please select a site';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildWorkerDropdown() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: DropdownButtonFormField<String>(
          value: _selectedWorkerId,
          isDense: true,
          decoration: InputDecoration(
            labelText: 'Select Worker',
            prefixIcon: const Icon(Icons.person, color: AppColors.primary, size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
          ),
          hint: const Text('Choose a worker'),
          isExpanded: true,
          items: _isLoadingWorkers
              ? []
              : _unassignedWorkers.map((worker) {
                  final mobile = worker['mobile'] as String? ?? '';
                  final displayText = mobile.isNotEmpty 
                      ? '${worker['name']} ($mobile)'
                      : worker['name'] as String;
                  return DropdownMenuItem<String>(
                    value: worker['id'] as String,
                    child: Text(
                      displayText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
          onChanged: _isLoadingWorkers
              ? null
              : (value) {
                  setState(() {
                    _selectedWorkerId = value;
                  });
                },
          validator: (value) {
            if (value == null) {
              return 'Please select a worker';
            }
            return null;
          },
        ),
      ),
    );
  }

  Future<void> _assignWorker() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final result = await _sitesService.assignWorkerToSite(
        token: token,
        siteId: _selectedSiteId!,
        workerId: _selectedWorkerId!,
      );

      if (result['success'] == true && mounted) {
        final workerName = _unassignedWorkers
            .firstWhere((w) => w['id'] == _selectedWorkerId)['name'];
        final siteName = _assignedSites
            .firstWhere((s) => s['id'] == _selectedSiteId)['name'];

        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Worker Assigned Successfully'),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$workerName has been assigned to $siteName!'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check, size: 16, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Assignment Complete',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Worker can now punch-in/out at this site',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  // Navigate to worker list screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkersInMySitesScreen(),
                    ),
                  );
                },
                child: const Text('View Workers'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _assignWorker,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
