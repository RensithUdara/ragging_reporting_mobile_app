import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/complaint_controller.dart';
import '../../models/complaint_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _witnessesController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  ComplaintCategory _selectedCategory = ComplaintCategory.other;
  Priority _selectedPriority = Priority.medium;
  bool _isAnonymous = false;

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    _witnessesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.report_problem,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Report a Ragging Incident',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your report will be treated confidentially and investigated thoroughly.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Incident Details
              _buildSectionHeader('Incident Details'),
              const SizedBox(height: 16),
              
              // Category Selection
              _buildDropdownField<ComplaintCategory>(
                label: 'Category *',
                value: _selectedCategory,
                items: ComplaintCategory.values,
                itemBuilder: (category) => ComplaintModel.categoryToString(category),
                onChanged: (value) => setState(() => _selectedCategory = value!),
              ),
              
              const SizedBox(height: 16),
              
              // Date Selection
              _buildDateTimeFields(),
              
              const SizedBox(height: 16),
              
              // Location
              CustomTextField(
                controller: _locationController,
                label: 'Incident Location *',
                hint: 'Where did the incident occur?',
                prefixIcon: Icons.location_on_outlined,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter the incident location';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Description
              _buildSectionHeader('Incident Description'),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _descriptionController,
                label: 'Description *',
                hint: 'Provide a detailed description of the incident...',
                maxLines: 6,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please provide a description of the incident';
                  }
                  if (value!.length < 20) {
                    return 'Please provide a more detailed description (at least 20 characters)';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Additional Information
              _buildSectionHeader('Additional Information'),
              const SizedBox(height: 16),
              
              // Priority
              _buildDropdownField<Priority>(
                label: 'Priority',
                value: _selectedPriority,
                items: Priority.values,
                itemBuilder: (priority) => ComplaintModel.priorityToString(priority),
                onChanged: (value) => setState(() => _selectedPriority = value!),
              ),
              
              const SizedBox(height: 16),
              
              // Witnesses
              CustomTextField(
                controller: _witnessesController,
                label: 'Witnesses (Optional)',
                hint: 'List any witnesses (separate with commas)',
                prefixIcon: Icons.people_outlined,
                maxLines: 2,
              ),
              
              const SizedBox(height: 24),
              
              // Anonymous Reporting
              _buildAnonymousToggle(),
              
              const SizedBox(height: 32),
              
              // Evidence Upload Section
              _buildEvidenceSection(),
              
              const SizedBox(height: 40),
              
              // Submit Button
              Consumer<ComplaintController>(
                builder: (context, complaintController, child) {
                  return CustomButton(
                    text: 'Submit Report',
                    onPressed: complaintController.isLoading ? null : _submitReport,
                    isLoading: complaintController.isLoading,
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Disclaimer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'By submitting this report, you confirm that the information provided is accurate to the best of your knowledge.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber[800],
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemBuilder(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateTimeFields() {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTimeField(),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date *',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select date',
                  style: TextStyle(
                    color: _selectedDate != null ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time *',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 12),
                Text(
                  _selectedTime != null
                      ? _selectedTime!.format(context)
                      : 'Select time',
                  style: TextStyle(
                    color: _selectedTime != null ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnonymousToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_off, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anonymous Report',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Your identity will be kept confidential',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAnonymous,
            onChanged: (value) => setState(() => _isAnonymous = value),
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evidence (Optional)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload photos, videos, or documents as evidence',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement file picker
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File upload - Coming Soon')),
              );
            },
            icon: const Icon(Icons.attach_file),
            label: const Text('Attach Evidence'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both date and time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final complaintController = Provider.of<ComplaintController>(context, listen: false);

      try {
        final witnesses = _witnessesController.text.isNotEmpty
            ? _witnessesController.text.split(',').map((e) => e.trim()).toList()
            : <String>[];

        await complaintController.submitComplaint(
          incidentLocation: _locationController.text.trim(),
          incidentDate: _selectedDate!,
          incidentTime: _selectedTime!.format(context),
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          isAnonymous: _isAnonymous,
          witnesses: witnesses.isEmpty ? null : witnesses,
          priority: _selectedPriority,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit report: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
