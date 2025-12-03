import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../utils/role_utils.dart';
import '../../widgets/custom_button.dart';
import '../coordinator/filtered_attendance_results_screen.dart';
import '../../services/sites_service.dart';

/// Attendance Management Screen for Admin
/// Allows filtering attendance by site, worker, and date range
/// Admin can see ALL sites and ALL users (workers + coordinators)
class AttendanceManagementScreen extends StatefulWidget {
  final String? preSelectedSiteId;
  final String? preSelectedSiteName;
  final String? preSelectedWorkerId;
  final String? preSelectedWorkerName;

  const AttendanceManagementScreen({
    super.key,
    this.preSelectedSiteId,
    this.preSelectedSiteName,
    this.preSelectedWorkerId,
    this.preSelectedWorkerName,
  });

  @override
  State<AttendanceManagementScreen> createState() =>
      _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState
    extends State<AttendanceManagementScreen> {
  String? _selectedSiteId;
  String? _selectedWorkerId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoadingSites = false;
  bool _isLoadingWorkers = false;

  List<Map<String, dynamic>> _sites = [];
  List<Map<String, dynamic>> _siteUsers = [];
  
  final SitesService _sitesService = SitesService();

  @override
  void initState() {
    super.initState();
    // Set pre-selected values if provided
    if (widget.preSelectedSiteId != null) {
      _selectedSiteId = widget.preSelectedSiteId;
    }
    if (widget.preSelectedWorkerId != null) {
      _selectedWorkerId = widget.preSelectedWorkerId;
    }
    _loadSites();
  }

  Future<void> _loadSites() async {
    setState(() {
      _isLoadingSites = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      final userRole = RoleUtils.getUserRole();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      // Admin gets all sites, coordinators get only their assigned sites
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
          _sites = fetchedSites;
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

  Future<void> _loadUsersForSite(String siteId) async {
    setState(() {
      _isLoadingWorkers = true;
      _selectedWorkerId = null; // Reset user selection
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      final userRole = RoleUtils.getUserRole();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final result = await _sitesService.getWorkersBySite(token: token, siteId: siteId);

      if (result['success'] == true) {
        final usersData = result['data']['workers'] as List<dynamic>;
        final fetchedUsers = usersData.map((user) => {
          'id': user['id'] as String,
          'name': user['name'] as String,
          'role': user['role'] as String? ?? '',
        }).toList();

        setState(() {
          _siteUsers = [
            {'id': 'all', 'name': 'All Users', 'role': ''},
            // Admin can see coordinators, regular coordinators see themselves
            if (userRole == 'admin')
              ...fetchedUsers  // All users including workers and coordinators
            else ...[
              {'id': 'myself', 'name': 'Myself', 'role': 'Site Coordinator'},
              ...fetchedUsers.where((u) => u['role'] == 'worker'),
            ],
          ];
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
            content: Text('Error loading users: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRole = RoleUtils.getUserRole();
    final isAdmin = userRole == 'admin';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Admin Attendance Management' : 'Attendance Management'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(isAdmin),
            const SizedBox(height: 24),

            // Filters Section
            _buildSectionHeader('Filters', Icons.filter_list),
            const SizedBox(height: 16),

            // Site Selection
            _buildSiteDropdown(),
            const SizedBox(height: 16),

            // User Selection (only shown if site is selected)
            if (_selectedSiteId != null) ...[
              _buildUserDropdown(isAdmin),
              const SizedBox(height: 16),
            ],

            // Date Range Section
            _buildSectionHeader('Date Range', Icons.date_range),
            const SizedBox(height: 16),
            _buildDateRangePickers(),
            const SizedBox(height: 32),

            // View Attendance Button
            CustomButton(
              text: 'View Attendance',
              onPressed: _canViewAttendance() ? _viewAttendance : () {},
              icon: Icons.visibility,
              backgroundColor: _canViewAttendance()
                  ? AppColors.primary
                  : AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isAdmin) {
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
              Icons.analytics,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAdmin ? 'Admin Filter Attendance' : 'Filter Attendance',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAdmin 
                      ? 'Access all sites and users'
                      : 'Select site, worker, and date range',
                  style: const TextStyle(
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
            fontSize: 18,
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
              : _sites.map((site) {
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
                      _loadUsersForSite(value);
                    }
                  });
                },
        ),
      ),
    );
  }

  Widget _buildUserDropdown(bool isAdmin) {
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
            labelText: isAdmin ? 'Select User' : 'Select Worker',
            prefixIcon: const Icon(Icons.person, color: AppColors.primary, size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
          ),
          hint: Text(isAdmin ? 'Choose a user' : 'Choose a worker'),
          isExpanded: true,
          items: _isLoadingWorkers
              ? []
              : _siteUsers.map((user) {
                  final isSpecialOption =
                      user['id'] == 'all' || user['id'] == 'myself';
                  final role = user['role'] as String? ?? '';
                  final displayName = role.isNotEmpty && !isSpecialOption
                      ? '${user['name']} ($role)'
                      : user['name'] as String;
                  
                  return DropdownMenuItem<String>(
                    value: user['id'] as String,
                    child: Row(
                      children: [
                        if (isSpecialOption)
                          Icon(
                            user['id'] == 'all'
                                ? Icons.groups
                                : Icons.person_pin,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        if (isSpecialOption) const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontWeight: isSpecialOption
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 14,
                              color: isSpecialOption
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
        ),
      ),
    );
  }

  Widget _buildDateRangePickers() {
    return Column(
      children: [
        // Start Date
        _buildDatePicker(
          label: 'Start Date',
          selectedDate: _startDate,
          onTap: () => _selectDate(isStartDate: true),
          icon: Icons.calendar_today,
        ),
        const SizedBox(height: 16),
        // End Date
        _buildDatePicker(
          label: 'End Date',
          selectedDate: _endDate,
          onTap: () => _selectDate(isStartDate: false),
          icon: Icons.event,
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
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
            color: AppColors.surfaceVariant,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedDate != null
                          ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                          : 'Select $label',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            selectedDate != null ? FontWeight.w500 : FontWeight.normal,
                        color: selectedDate != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If end date is before start date, reset it
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          // Validate end date is not before start date
          if (_startDate != null && picked.isBefore(_startDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('End date cannot be before start date'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }
          _endDate = picked;
        }
      });
    }
  }

  bool _canViewAttendance() {
    return _selectedSiteId != null &&
        _selectedWorkerId != null &&
        _startDate != null &&
        _endDate != null;
  }

  void _viewAttendance() {
    if (!_canViewAttendance()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all filters before viewing attendance'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Get selected site and user names for display
    final siteName = _sites
        .firstWhere((s) => s['id'] == _selectedSiteId)['name'] as String;
    final userName = _siteUsers
        .firstWhere((w) => w['id'] == _selectedWorkerId)['name'] as String;

    // Navigate to filtered attendance results with all parameters
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredAttendanceResultsScreen(
          siteId: _selectedSiteId!,
          siteName: siteName,
          workerId: _selectedWorkerId!,
          workerName: userName,
          startDate: _startDate!,
          endDate: _endDate!,
        ),
      ),
    );
  }
}
