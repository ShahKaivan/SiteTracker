import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../services/announcements_service.dart';

/// Create Announcement Screen for Site Coordinators
/// Allows coordinators to create announcements for their assigned sites
class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  String? _selectedSiteId;
  String _selectedPriority = 'medium';
  DateTime? _expiryDate;
  bool _isLoading = false;
  bool _isLoadingSites = false;

  // Placeholder data - will be replaced with API calls
  final List<Map<String, dynamic>> _assignedSites = [
    {'id': '11111111-1111-1111-1111-111111111111', 'name': 'Construction Site A', 'code': 'CS-A'},
    {'id': '22222222-2222-2222-2222-222222222222', 'name': 'Construction Site B', 'code': 'CS-B'},
    {'id': '33333333-3333-3333-3333-333333333333', 'name': 'Renovation Site C', 'code': 'RS-C'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAssignedSites();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignedSites() async {
    setState(() {
      _isLoadingSites = true;
    });

    // TODO: Fetch sites from API
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // final userId = authProvider.user?.id;
    // await ApiService.getSiteAssignments(userId);

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoadingSites = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Announcement'),
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
              _buildSectionHeader('Target Site', Icons.location_city),
              const SizedBox(height: 12),
              _buildSiteDropdown(),
              const SizedBox(height: 24),

              // Announcement Details
              _buildSectionHeader('Announcement Details', Icons.campaign),
              const SizedBox(height: 12),

              // Title Input
              CustomInput(
                controller: _titleController,
                labelText: 'Title',
                hintText: 'Enter announcement title',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.length < 5) {
                    return 'Title must be at least 5 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Message Input
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Message',
                  hintText: 'Enter announcement message',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Icon(Icons.message),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  if (value.length < 10) {
                    return 'Message must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Priority Selection
              _buildSectionHeader('Priority Level', Icons.flag),
              const SizedBox(height: 12),
              _buildPrioritySelection(),
              const SizedBox(height: 24),

              // Expiry Date
              _buildSectionHeader('Expiry Date (Optional)', Icons.event_busy),
              const SizedBox(height: 12),
              _buildExpiryDatePicker(),
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: 'Create Announcement',
                onPressed: _isLoading ? () {} : _createAnnouncement,
                icon: Icons.send,
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
              Icons.campaign,
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
                  'New Announcement',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Share important updates with workers',
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
          decoration: InputDecoration(
            labelText: 'Select Site',
            prefixIcon:
                const Icon(Icons.location_city, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
          ),
          hint: const Text('Choose a site for this announcement'),
          isExpanded: true,
          items: _isLoadingSites
              ? []
              : _assignedSites.map((site) {
                  return DropdownMenuItem<String>(
                    value: site['id'] as String,
                    child: Text(
                      site['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
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
    );
  }

  Widget _buildPrioritySelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildPriorityChip('Low', 'low', Colors.blue),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityChip('Medium', 'medium', Colors.orange),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityChip('High', 'high', Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String label, String value, Color color) {
    final isSelected = _selectedPriority == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPriority = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? color : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryDatePicker() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _selectExpiryDate,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surfaceVariant,
          ),
          child: Row(
            children: [
              const Icon(Icons.event_busy, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expiry Date',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _expiryDate != null
                          ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                          : 'No expiry date (optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            _expiryDate != null ? FontWeight.w500 : FontWeight.normal,
                        color: _expiryDate != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (_expiryDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _expiryDate = null;
                        });
                      },
                      color: Colors.grey.shade600,
                      tooltip: 'Clear date',
                    ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
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

    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _createAnnouncement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get auth token
      final token = authProvider.token;
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      // Call API to create announcement
      final announcementsService = AnnouncementsService();
      final result = await announcementsService.createAnnouncement(
        token: token,
        siteId: _selectedSiteId!,
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        priority: _selectedPriority,
        expiryDate: _expiryDate,
      );

      if (result['success'] != true) {
        throw Exception('Failed to create announcement');
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
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text('Success'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Announcement "${_titleController.text}" has been created successfully!',
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(_selectedPriority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag,
                        color: _getPriorityColor(_selectedPriority),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Priority: ${_selectedPriority.toUpperCase()}',
                        style: TextStyle(
                          color: _getPriorityColor(_selectedPriority),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
            content: Text('Error creating announcement: ${e.toString()}'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _createAnnouncement,
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

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
