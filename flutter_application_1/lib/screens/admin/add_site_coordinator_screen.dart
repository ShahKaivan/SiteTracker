import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../services/sites_service.dart';

/// Add Site Coordinator Screen for Admin
/// Allows administrators to assign site coordinators to sites without one
class AddSiteCoordinatorScreen extends StatefulWidget {
  const AddSiteCoordinatorScreen({super.key});

  @override
  State<AddSiteCoordinatorScreen> createState() => _AddSiteCoordinatorScreenState();
}

class _AddSiteCoordinatorScreenState extends State<AddSiteCoordinatorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedSiteId;
  String? _selectedCoordinatorId;
  
  bool _isLoading = false;
  bool _isLoadingSites = false;
  bool _isLoadingCoordinators = false;
  
  List<Map<String, dynamic>> _sitesWithoutCoordinator = [];
  List<Map<String, dynamic>> _siteCoordinators = [];

  final SitesService _sitesService = SitesService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadSitesWithoutCoordinator(),
      _loadSiteCoordinators(),
    ]);
  }

  Future<void> _loadSitesWithoutCoordinator() async {
    setState(() {
      _isLoadingSites = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final result = await _sitesService.getSitesWithoutCoordinator(token: token);

      if (result['success'] == true) {
        final sitesData = result['data']['sites'] as List<dynamic>;
        final fetchedSites = sitesData.map((site) => {
          'id': site['id'] as String,
          'name': site['name'] as String,
          'code': site['code'] as String? ?? '',
        }).toList();

        setState(() {
          _sitesWithoutCoordinator = fetchedSites;
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

  Future<void> _loadSiteCoordinators() async {
    setState(() {
      _isLoadingCoordinators = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final result = await _sitesService.getSiteCoordinators(token: token);

      if (result['success'] == true) {
        final coordinatorsData = result['data']['coordinators'] as List<dynamic>;
        final fetchedCoordinators = coordinatorsData.map((coordinator) => {
          'id': coordinator['id'] as String,
          'name': coordinator['full_name'] as String? ?? 'Unnamed',
          'mobile': coordinator['mobile_number'] as String? ?? '',
        }).toList();

        setState(() {
          _siteCoordinators = fetchedCoordinators;
          _isLoadingCoordinators = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCoordinators = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading coordinators: ${e.toString()}'),
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
        title: const Text('Add Site Coordinator'),
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
              const SizedBox(height:24),

              // Site Selection
              _buildSectionHeader('Select Site', Icons.location_city),
              const SizedBox(height: 12),
              _buildSiteDropdown(),
              const SizedBox(height: 24),

              // Coordinator Selection
              _buildSectionHeader('Select Site Coordinator', Icons.person),
              const SizedBox(height: 12),
              _buildCoordinatorDropdown(),
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: 'Assign Coordinator',
                onPressed: _isLoading ? () {} : _assignCoordinator,
                icon: Icons.person_add,
                isLoading: _isLoading,
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
              Icons.admin_panel_settings,
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
                  'Assign Coordinator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Assign a site coordinator to manage a site',
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
          hint: _isLoadingSites 
              ? const Text('Loading sites...')
              : Text(_sitesWithoutCoordinator.isEmpty 
                  ? 'No sites available' 
                  : 'Choose a site'),
          isExpanded: true,
          items: _isLoadingSites
              ? []
              : _sitesWithoutCoordinator.map((site) {
                  final code = site['code'] as String;
                  final displayText = code.isNotEmpty 
                      ? '${site['name']} ($code)'
                      : site['name'] as String;
                  return DropdownMenuItem<String>(
                    value: site['id'] as String,
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
          onChanged: _isLoadingSites || _sitesWithoutCoordinator.isEmpty
              ? null
              : (value) {
                  setState(() {
                    _selectedSiteId = value;
                  });
                },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a site';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildCoordinatorDropdown() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: DropdownButtonFormField<String>(
          value: _selectedCoordinatorId,
          isDense: true,
          decoration: InputDecoration(
            labelText: 'Select Coordinator',
            prefixIcon: const Icon(Icons.person, color: AppColors.primary, size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
          ),
          hint: _isLoadingCoordinators 
              ? const Text('Loading coordinators...')
              : Text(_siteCoordinators.isEmpty 
                  ? 'No coordinators available' 
                  : 'Choose a coordinator'),
          isExpanded: true,
          items: _isLoadingCoordinators
              ? []
              : _siteCoordinators.map((coordinator) {
                  final mobile = coordinator['mobile'] as String;
                  final displayText = mobile.isNotEmpty
                      ? '${coordinator['name']} ($mobile)'
                      : coordinator['name'] as String;
                  return DropdownMenuItem<String>(
                    value: coordinator['id'] as String,
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
          onChanged: _isLoadingCoordinators || _siteCoordinators.isEmpty
              ? null
              : (value) {
                  setState(() {
                    _selectedCoordinatorId = value;
                  });
                },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a coordinator';
            }
            return null;
          },
        ),
      ),
    );
  }

  Future<void> _assignCoordinator() async {
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

      // Get selected site and coordinator names for display
      final selectedSite = _sitesWithoutCoordinator.firstWhere(
        (site) => site['id'] == _selectedSiteId,
      );
      final selectedCoordinator = _siteCoordinators.firstWhere(
        (coordinator) => coordinator['id'] == _selectedCoordinatorId,
      );

      // Call API to assign coordinator
      final result = await _sitesService.assignCoordinatorToSite(
        token: token,
        siteId: _selectedSiteId!,
        coordinatorId: _selectedCoordinatorId!,
      );

      if (result['success'] != true) {
        throw Exception('Failed to assign coordinator');
      }

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 28),
                SizedBox(width: 12),
                Text('Success'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${selectedCoordinator['name']} has been assigned to ${selectedSite['name']}!',
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_city,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Site: ${selectedSite['name']}',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
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
                  Navigator.pop(context); // Go back to previous screen
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
            content: Text('Error assigning coordinator: ${e.toString()}'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _assignCoordinator,
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
