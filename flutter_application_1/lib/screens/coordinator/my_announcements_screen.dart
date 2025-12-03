import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../models/announcement_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state.dart';
import '../../services/announcements_service.dart';
import '../../services/sites_service.dart';
import '../../utils/role_utils.dart';

/// My Announcements Screen for Site Coordinators
/// Displays all announcements created by the coordinator with filtering and management options
class MyAnnouncementsScreen extends StatefulWidget {
  const MyAnnouncementsScreen({super.key});

  @override
  State<MyAnnouncementsScreen> createState() => _MyAnnouncementsScreenState();
}

class _MyAnnouncementsScreenState extends State<MyAnnouncementsScreen> {
  String? _selectedSiteFilter;
  bool _isLoading = false;
  bool _isLoadingSites = false;
  List<AnnouncementModel> _announcements = [];
  List<Map<String, dynamic>> _sites = [
    {'id': 'all', 'name': 'All Sites'},
  ];
  String? _errorMessage;
  
  final AnnouncementsService _announcementsService = AnnouncementsService();
  final SitesService _sitesService = SitesService();

  @override
  void initState() {
    super.initState();
    _selectedSiteFilter = 'all';
    _loadSites();
    _loadAnnouncements();
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
          _sites = [
            {'id': 'all', 'name': 'All Sites'},
            ...fetchedSites,
          ];
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

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final siteId = _selectedSiteFilter == 'all' ? null : _selectedSiteFilter;
      final result = await _announcementsService.getMyAnnouncements(
        token: token,
        siteId: siteId,
      );

      if (result['success'] == true) {
        final announcementsData = result['data']['announcements'] as List<dynamic>;
        final fetchedAnnouncements = announcementsData
            .map((announcement) =>
                AnnouncementModel.fromJson(announcement as Map<String, dynamic>))
            .toList();

        setState(() {
          _announcements = fetchedAnnouncements;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading announcements: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }



  List<AnnouncementModel> get _filteredAnnouncements {
    if (_selectedSiteFilter == null || _selectedSiteFilter == 'all') {
      return _announcements;
    }
    return _announcements
        .where((a) => a.siteId == _selectedSiteFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Announcements'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnnouncements,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Site Filter
          _buildSiteFilter(),

          // Statistics Bar
          if (_filteredAnnouncements.isNotEmpty) _buildStatisticsBar(),

          // Announcements List
          Expanded(child: _buildAnnouncementsList()),
        ],
      ),
    );
  }

  Widget _buildSiteFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedSiteFilter,
              decoration: InputDecoration(
                labelText: 'Filter by Site',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
              ),
              isExpanded: true,
              items: _sites.map((site) {
                return DropdownMenuItem<String>(
                  value: site['id'] as String,
                  child: Text(
                    site['name'] as String,
                    style: TextStyle(
                      fontWeight: site['id'] == 'all'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSiteFilter = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsBar() {
    final activeCount =
        _filteredAnnouncements.where((a) => !a.isExpired).length;
    final expiredCount =
        _filteredAnnouncements.where((a) => a.isExpired).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total',
            _filteredAnnouncements.length.toString(),
            Icons.campaign,
            AppColors.primary,
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          _buildStatItem(
            'Active',
            activeCount.toString(),
            Icons.check_circle,
            AppColors.success,
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          _buildStatItem(
            'Expired',
            expiredCount.toString(),
            Icons.event_busy,
            AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_filteredAnnouncements.isEmpty) {
      return EmptyState(
        icon: Icons.campaign_outlined,
        title: 'No announcements yet',
        message: _selectedSiteFilter == 'all'
            ? 'You haven\'t created any announcements.'
            : 'No announcements for the selected site.',
        actionLabel: 'Refresh',
        onAction: _loadAnnouncements,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAnnouncements,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredAnnouncements.length,
        itemBuilder: (context, index) {
          final announcement = _filteredAnnouncements[index];
          return _buildAnnouncementCard(announcement);
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel announcement) {
    final priorityColor = announcement.priorityColor;
    final isExpired = announcement.isExpired;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: priorityColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority Icon
                Container(
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
                const SizedBox(width: 12),
                // Title and Priority
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isExpired
                              ? Colors.grey.shade600
                              : Colors.black,
                          decoration:
                              isExpired ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
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
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: priorityColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status Chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isExpired
                                  ? Colors.grey.shade200
                                  : AppColors.success.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isExpired ? 'EXPIRED' : 'ACTIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isExpired
                                    ? Colors.grey.shade600
                                    : AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Message
            Text(
              announcement.message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Footer
            Row(
              children: [
                // Site Name
                if (announcement.siteName != null) ...[
                  Icon(Icons.location_on,
                      size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      announcement.siteName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                // Created Date
                Icon(Icons.calendar_today,
                    size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  announcement.formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (announcement.expiryDate != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.event_busy, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Expires: ${announcement.expiryDate!.day}/${announcement.expiryDate!.month}/${announcement.expiryDate!.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isExpired ? AppColors.error : Colors.grey.shade600,
                      fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showAnnouncementDetails(announcement),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                if (!isExpired)
                  TextButton.icon(
                    onPressed: () => _deactivateAnnouncement(announcement),
                    icon: const Icon(Icons.block, size: 16),
                    label: const Text('Deactivate'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAnnouncementDetails(AnnouncementModel announcement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: announcement.priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.campaign,
                        color: announcement.priorityColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        announcement.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    announcement.message,
                    style: const TextStyle(fontSize: 15, height: 1.6),
                  ),
                ),
                const SizedBox(height: 24),
                // Details
                _buildDetailRow('Site', announcement.siteName ?? 'N/A',
                    Icons.location_on),
                const Divider(),
                _buildDetailRow(
                    'Priority',
                    announcement.priority.toUpperCase(),
                    Icons.flag,
                    announcement.priorityColor),
                const Divider(),
                _buildDetailRow('Status', announcement.isExpired ? 'Expired' : 'Active',
                    Icons.info_outline,
                    announcement.isExpired ? AppColors.error : AppColors.success),
                const Divider(),
                _buildDetailRow('Published', announcement.formattedDate,
                    Icons.calendar_today),
                if (announcement.expiryDate != null) ...[
                  const Divider(),
                  _buildDetailRow(
                    'Expires',
                    '${announcement.expiryDate!.day}/${announcement.expiryDate!.month}/${announcement.expiryDate!.year}',
                    Icons.event_busy,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon,
      [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey.shade600),
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
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deactivateAnnouncement(AnnouncementModel announcement) async {
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
            Text('Deactivate Announcement?'),
          ],
        ),
        content: Text(
          'Are you sure you want to deactivate "${announcement.title}"?\n\nThis will hide it from workers immediately.',
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
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final token = authProvider.token;

        if (token == null || token.isEmpty) {
          throw Exception('Authentication token not found');
        }

        final result = await _announcementsService.deactivateAnnouncement(
          token: token,
          announcementId: announcement.id,
        );

        if (result['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Deactivated "${announcement.title}"'),
                backgroundColor: AppColors.success,
              ),
            );

            // Reload announcements
            _loadAnnouncements();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deactivating announcement: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
