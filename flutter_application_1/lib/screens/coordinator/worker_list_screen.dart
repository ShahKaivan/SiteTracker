import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/empty_state.dart';

/// Worker List Screen for Site Coordinators
/// Displays all workers assigned to coordinator's sites
class WorkerListScreen extends StatefulWidget {
  const WorkerListScreen({super.key});

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  bool _isLoading = false;
  String? _selectedSiteFilter;
  
  // Placeholder data
  final List<Map<String, dynamic>> _sites = [
    {'id': 'all', 'name': 'All Sites'},
    {'id': '1', 'name': 'Construction Site A'},
    {'id': '2', 'name': 'Construction Site B'},
  ];

  final List<Map<String, dynamic>> _workers = [
    {
      'id': '1',
      'name': 'John Doe',
      'mobile': '+91 9876543210',
      'site': 'Construction Site A',
      'role': 'worker',
      'active': true,
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'mobile': '+91 9876543211',
      'site': 'Construction Site A',
      'role': 'worker',
      'active': true,
    },
    {
      'id': '3',
      'name': 'Mike Johnson',
      'mobile': '+91 9876543212',
      'site': 'Construction Site B',
      'role': 'worker',
      'active': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedSiteFilter = 'all';
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredWorkers {
    if (_selectedSiteFilter == 'all') {
      return _workers;
    }
    return _workers
        .where((w) => w['site'] == _sites.firstWhere((s) => s['id'] == _selectedSiteFilter)['name'])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workers'),
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
          // Site Filter
          _buildSiteFilter(),
          
          // Workers List
          Expanded(child: _buildWorkersList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Worker'),
        backgroundColor: AppColors.primary,
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      fontWeight: site['id'] == 'all' ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildWorkersList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredWorkers.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline,
        title: 'No workers found',
        message: 'No workers assigned to the selected site',
        actionLabel: 'Refresh',
        onAction: _loadWorkers,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWorkers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredWorkers.length,
        itemBuilder: (context, index) {
          final worker = _filteredWorkers[index];
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.person,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        title: Text(
          worker['name'] as String,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(worker['mobile'] as String),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    worker['site'] as String,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: worker['active'] == true
                ? AppColors.success.withOpacity(0.2)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            worker['active'] == true ? 'ACTIVE' : 'INACTIVE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: worker['active'] == true
                  ? AppColors.success
                  : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}
