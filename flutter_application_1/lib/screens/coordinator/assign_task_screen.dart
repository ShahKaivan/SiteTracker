import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

/// Screen to assign tasks to workers
class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({super.key});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedWorker;
  String? _selectedPriority = 'medium';
  DateTime? _dueDate;

  // Placeholder data for workers
  final List<Map<String, String>> _workers = [
    {'id': '1', 'name': 'John Doe', 'role': 'Construction Worker'},
    {'id': '2', 'name': 'Jane Smith', 'role': 'Electrician'},
    {'id': '3', 'name': 'Mike Johnson', 'role': 'Plumber'},
    {'id': '4', 'name': 'Sarah Williams', 'role': 'Painter'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Task'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildSectionHeader('Task Details'),
              const SizedBox(height: 16),
              
              // Task Title
              CustomInput(
                controller: _titleController,
                labelText: 'Task Title',
                hintText: 'Enter task title',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Task Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task description',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.description),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter task description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Assignment Section
              _buildSectionHeader('Assignment'),
              const SizedBox(height: 16),
              
              // Worker Selection
              _buildWorkerDropdown(),
              const SizedBox(height: 16),
              
              // Priority Selection
              _buildPrioritySelection(),
              const SizedBox(height: 16),
              
              // Due Date
              _buildDueDatePicker(),
              const SizedBox(height: 32),
              
              // Submit Button
              CustomButton(
                text: 'Assign Task',
                onPressed: _assignTask,
                icon: Icons.assignment_turned_in,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildWorkerDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedWorker,
      decoration: InputDecoration(
        labelText: 'Assign to Worker',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      hint: const Text('Select a worker'),
      items: _workers.map((worker) {
        return DropdownMenuItem<String>(
          value: worker['id'],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                worker['name']!,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                worker['role']!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedWorker = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a worker';
        }
        return null;
      },
    );
  }

  Widget _buildPrioritySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
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
      ],
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
          color: isSelected ? color.withOpacity(0.2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
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
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDueDatePicker() {
    return InkWell(
      onTap: _selectDueDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Due Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dueDate != null
                        ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                        : 'Select due date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: _dueDate != null ? FontWeight.w500 : FontWeight.normal,
                      color: _dueDate != null ? Colors.black : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _assignTask() {
    if (_formKey.currentState!.validate()) {
      if (_dueDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a due date'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Get worker name
      final workerName = _workers.firstWhere(
        (w) => w['id'] == _selectedWorker,
        orElse: () => {'name': 'Unknown'},
      )['name'];

      // Show success dialog
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
              Text('Task Assigned'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Task "${_titleController.text}" has been assigned to $workerName.'),
              const SizedBox(height: 8),
              Text(
                'Priority: ${_selectedPriority!.toUpperCase()}',
                style: TextStyle(
                  color: _getPriorityColor(_selectedPriority!),
                  fontWeight: FontWeight.bold,
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
