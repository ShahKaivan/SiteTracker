import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../services/sites_service.dart';

/// Add Site Screen for Admin
/// Allows administrators to create new sites
class AddSiteScreen extends StatefulWidget {
  const AddSiteScreen({super.key});

  @override
  State<AddSiteScreen> createState() => _AddSiteScreenState();
}

class _AddSiteScreenState extends State<AddSiteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _isLoading = false;

  final SitesService _sitesService = SitesService();

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Site'),
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

              // Site Details Section
              _buildSectionHeader('Site Details', Icons.business),
              const SizedBox(height: 12),

              // Site Code Input
              CustomInput(
                controller: _codeController,
                labelText: 'Site Code',
                hintText: 'Enter unique site code (optional)',
                prefixIcon: Icons.tag,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 2) {
                    return 'Site code must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Site Name Input
              CustomInput(
                controller: _nameController,
                labelText: 'Site Name',
                hintText: 'Enter site name',
                prefixIcon: Icons.location_city,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a site name';
                  }
                  if (value.length < 3) {
                    return 'Site name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Location Details Section
              _buildSectionHeader('Location Details (Optional)', Icons.place),
              const SizedBox(height: 12),

              // Address Input
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter site address',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 45),
                    child: Icon(Icons.home),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Latitude and Longitude
              Row(
                children: [
                  Expanded(
                    child: CustomInput(
                      controller: _latitudeController,
                      labelText: 'Latitude',
                      hintText: 'e.g. 28.6139',
                      prefixIcon: Icons.my_location,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final lat = double.tryParse(value);
                          if (lat == null || lat < -90 || lat > 90) {
                            return 'Invalid latitude';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomInput(
                      controller: _longitudeController,
                      labelText: 'Longitude',
                      hintText: 'e.g. 77.2090',
                      prefixIcon: Icons.location_on,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final lng = double.tryParse(value);
                          if (lng == null || lng < -180 || lng > 180) {
                            return 'Invalid longitude';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: 'Create Site',
                onPressed: _isLoading ? () {} : _createSite,
                icon: Icons.add_location,
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
              Icons.add_location_alt,
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
                  'New Site',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Add a new construction site to the system',
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

  Future<void> _createSite() async {
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

      // Prepare site data
      final siteData = {
        'name': _nameController.text.trim(),
        if (_codeController.text.trim().isNotEmpty)
          'code': _codeController.text.trim(),
        if (_addressController.text.trim().isNotEmpty)
          'address': _addressController.text.trim(),
        if (_latitudeController.text.trim().isNotEmpty)
          'latitude': _latitudeController.text.trim(),
        if (_longitudeController.text.trim().isNotEmpty)
          'longitude': _longitudeController.text.trim(),
      };

      // Call API to create site
      final result = await _sitesService.createSite(
        token: token,
        siteData: siteData,
      );

      if (result['success'] != true) {
        throw Exception('Failed to create site');
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
                  'Site "${_nameController.text}" has been created successfully!',
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
                          _codeController.text.trim().isNotEmpty
                              ? 'Code: ${_codeController.text.trim()}'
                              : 'No site code',
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
            content: Text('Error creating site: ${e.toString()}'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _createSite,
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
