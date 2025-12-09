import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../services/sites_service.dart';
import 'package:intl/intl.dart';

/// Worker Site Assignment Screen
/// Allows workers to self-assign to sites and leave sites
class WorkerSiteAssignmentScreen extends StatefulWidget {
  const WorkerSiteAssignmentScreen({super.key});

  @override
  State<WorkerSiteAssignmentScreen> createState() => _WorkerSiteAssignmentScreenState();
}

class _WorkerSiteAssignmentScreenState extends State<WorkerSiteAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedSiteId;
  bool _isLoading = false;
  bool _isLoadingSites = false;
  bool _isLoadingAssignment = false;

  List<Map<String, dynamic>> _availableSites = [];
  Map<String, dynamic>? _currentAssignment;
  
  final SitesService _sitesService = SitesService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadCurrentAssignment(),
      _loadAvailableSites(),
    ]);
  }

  Future<void> _loadCurrentAssignment() async {
    setState(() {
      _isLoadingAssignment = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final result = await _sitesService.getMyCurrentSiteAssignment(token: token);

      if (result['success'] == true && mounted) {
        setState(() {
          _currentAssignment = result['data']['assignment'] as Map<String, dynamic>?;
          _isLoadingAssignment = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAssignment = false;
        });
        // Don't show error if no assignment found - this is normal
      }
    }
  }

  Future<void> _loadAvailableSites() async {
    setState(() {
      _isLoadingSites = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final result = await _sitesService.getAllSites(token: token);

      if (result['success'] == true) {
        final sitesData = result['data']['sites'] as List<dynamic>;
        final fetchedSites = sitesData.map((site) => {
          'id': site['id'] as String,
          'name': site['name'] as String,
          'code': site['code'] as String? ?? '',
        }).toList();

        setState(() {
          _availableSites = fetchedSites;
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

  Future<void> _joinSite() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      final userId = authProvider.user?.id;

      if (token == null || token.isEmpty || userId == null) {
        throw Exception('Authentication information not found');
      }

      final result = await _sitesService.assignWorkerToSite(
        token: token,
        siteId: _selectedSiteId!,
        workerId: userId,
      );

      if (result['success'] == true && mounted) {
        final siteName = _availableSites
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
                const Expanded(
                  child: Text('Joined Site Successfully'),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You have been assigned to $siteName!'),
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
                        'You can now punch-in/out at this site',
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
                  // Reload data to show new assignment
                  _loadData();
                },
                child: const Text('OK'),
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
              onPressed: _joinSite,
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

  Future<void> _leaveSite() async {
    if (_currentAssignment == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text('Leave Site?'),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to leave ${_currentAssignment!['site_name']}?\n\nYou will not be able to punch-in/out until you join another site.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Leave Site'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      final userId = authProvider.user?.id;

      if (token == null || token.isEmpty || userId == null) {
        throw Exception('Authentication information not found');
      }

      final result = await _sitesService.removeWorkerFromSite(
        token: token,
        siteId: _currentAssignment!['site_id'] as String,
        workerId: userId,
      );

      if (result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully left the site'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload data to clear assignment
        await _loadData();
        
        setState(() {
          _selectedSiteId = null;
        });
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
              onPressed: _leaveSite,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Site Assignment'),
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

              if (_isLoadingAssignment)
                const Center(child: CircularProgressIndicator())
              else if (_currentAssignment != null)
                // Show current assignment
                _buildCurrentAssignmentSection()
              else
                // Show site selection
                _buildSiteSelectionSection(),

              const SizedBox(height: 16),

              // Info Box
              _buildInfoBox(),
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
              Icons.business,
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
                  'Site Assignment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage your site assignment',
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

  Widget _buildCurrentAssignmentSection() {
    final siteName = _currentAssignment!['site_name'] as String;
    final siteCode = _currentAssignment!['site_code'] as String? ?? '';
    final assignedAt = _currentAssignment!['assigned_at'] as String?;

    String formattedDate = 'N/A';
    if (assignedAt != null) {
      try {
        final date = DateTime.parse(assignedAt);
        formattedDate = DateFormat('MMM dd, yyyy').format(date);
      } catch (e) {
        formattedDate = 'N/A';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_city, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Current Assignment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.business,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            siteName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (siteCode.isNotEmpty)
                            Text(
                              'Code: $siteCode',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Assigned since $formattedDate',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Leave Site Button
        CustomButton(
          text: 'Leave Site',
          onPressed: _isLoading ? () {} : _leaveSite,
          icon: Icons.exit_to_app,
          isLoading: _isLoading,
          backgroundColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildSiteSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_city, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Join a Site',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Card(
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
              hint: const Text('Choose a site to join'),
              isExpanded: true,
              items: _isLoadingSites
                  ? []
                  : _availableSites.map((site) {
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
        ),
        const SizedBox(height: 24),

        // Join Site Button
        CustomButton(
          text: 'Join Site',
          onPressed: _isLoading ? () {} : _joinSite,
          icon: Icons.add_business,
          isLoading: _isLoading,
          backgroundColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
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
                  'About Site Assignment',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '• You can only be assigned to ONE site at a time\n'
                  '• You must leave your current site before joining another\n'
                  '• You can punch-in/out only at your assigned site',
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
    );
  }
}
