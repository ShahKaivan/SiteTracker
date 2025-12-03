import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// Screen to approve or reject submitted tasks
class TaskApprovalsScreen extends StatefulWidget {
  const TaskApprovalsScreen({super.key});

  @override
  State<TaskApprovalsScreen> createState() => _TaskApprovalsScreenState();
}

class _TaskApprovalsScreenState extends State<TaskApprovalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Placeholder data for tasks
  final List<Map<String, dynamic>> _pendingTasks = [
    {
      'id': '1',
      'title': 'Install electrical wiring - Floor 2',
      'description': 'Complete electrical wiring installation for second floor',
      'workerName': 'Jane Smith',
      'workerRole': 'Electrician',
      'submittedDate': '2024-12-24',
      'priority': 'high',
      'status': 'pending',
      'imageUrl': null,
    },
    {
      'id': '2',
      'title': 'Paint living room walls',
      'description': 'Apply two coats of white paint to living room walls',
      'workerName': 'Sarah Williams',
      'workerRole': 'Painter',
      'submittedDate': '2024-12-24',
      'priority': 'medium',
      'status': 'pending',
      'imageUrl': null,
    },
    {
      'id': '3',
      'title': 'Fix bathroom plumbing',
      'description': 'Repair leaking pipes in bathroom',
      'workerName': 'Mike Johnson',
      'workerRole': 'Plumber',
      'submittedDate': '2024-12-23',
      'priority': 'high',
      'status': 'pending',
      'imageUrl': null,
    },
  ];

  final List<Map<String, dynamic>> _reviewedTasks = [
    {
      'id': '4',
      'title': 'Concrete foundation work',
      'description': 'Lay concrete foundation for new structure',
      'workerName': 'John Doe',
      'workerRole': 'Construction Worker',
      'submittedDate': '2024-12-22',
      'reviewedDate': '2024-12-23',
      'priority': 'high',
      'status': 'approved',
      'imageUrl': null,
    },
    {
      'id': '5',
      'title': 'Install door frames',
      'description': 'Install wooden door frames in all rooms',
      'workerName': 'John Doe',
      'workerRole': 'Construction Worker',
      'submittedDate': '2024-12-21',
      'reviewedDate': '2024-12-22',
      'priority': 'medium',
      'status': 'rejected',
      'rejectionReason': 'Measurements not accurate',
      'imageUrl': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Approvals'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Pending'),
                  const SizedBox(width: 8),
                  if (_pendingTasks.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _pendingTasks.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Tab(text: 'Reviewed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(),
          _buildReviewedTab(),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_pendingTasks.isEmpty) {
      return _buildEmptyState('No pending tasks', Icons.task_alt);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingTasks.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(_pendingTasks[index], isPending: true);
      },
    );
  }

  Widget _buildReviewedTab() {
    if (_reviewedTasks.isEmpty) {
      return _buildEmptyState('No reviewed tasks', Icons.history);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviewedTasks.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(_reviewedTasks[index], isPending: false);
      },
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, {required bool isPending}) {
    final priority = task['priority'] as String;
    final priorityColor = _getPriorityColor(priority);
    final status = task['status'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: priorityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showTaskDetails(task, isPending),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      priority.toUpperCase(),
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task['description'] as String,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      task['workerName'].toString()[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['workerName'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          task['workerRole'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isPending)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'approved'
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            status == 'approved' ? Icons.check_circle : Icons.cancel,
                            color: status == 'approved' ? Colors.green : Colors.red,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status == 'approved' ? 'Approved' : 'Rejected',
                            style: TextStyle(
                              color: status == 'approved' ? Colors.green : Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Submitted: ${task['submittedDate']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(Map<String, dynamic> task, bool isPending) {
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                task['title'] as String,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(task['priority'] as String).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${task['priority'].toString().toUpperCase()} PRIORITY',
                  style: TextStyle(
                    color: _getPriorityColor(task['priority'] as String),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task['description'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Submitted By',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      task['workerName'].toString()[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['workerName'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        task['workerRole'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Submitted Date', task['submittedDate'] as String),
              if (!isPending) ...[
                _buildDetailRow('Reviewed Date', task['reviewedDate'] as String),
                _buildDetailRow(
                  'Status',
                  task['status'] == 'approved' ? 'Approved' : 'Rejected',
                ),
                if (task['status'] == 'rejected' && task['rejectionReason'] != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Rejection Reason',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task['rejectionReason'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ],
              if (isPending) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rejectTask(task),
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveTask(task),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _approveTask(Map<String, dynamic> task) {
    Navigator.pop(context); // Close bottom sheet
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Task Approved'),
          ],
        ),
        content: Text('Task "${task['title']}" has been approved successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _pendingTasks.remove(task);
                task['status'] = 'approved';
                task['reviewedDate'] = '2024-12-24';
                _reviewedTasks.insert(0, task);
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _rejectTask(Map<String, dynamic> task) {
    Navigator.pop(context); // Close bottom sheet
    
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Reject Task'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Please provide a reason for rejecting "${task['title']}":'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a rejection reason'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              setState(() {
                _pendingTasks.remove(task);
                task['status'] = 'rejected';
                task['reviewedDate'] = '2024-12-24';
                task['rejectionReason'] = reasonController.text;
                _reviewedTasks.insert(0, task);
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task rejected'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.blue;
    }
  }
}
