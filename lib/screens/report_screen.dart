import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:ragging_reporting_app/utils/validators.dart';
import 'package:ragging_reporting_app/widgets/custom_button.dart';
import 'package:ragging_reporting_app/widgets/custom_text_field.dart';
import 'package:ragging_reporting_app/widgets/custom_dropdown.dart';
import 'package:ragging_reporting_app/widgets/custom_date_picker.dart';
import 'package:ragging_reporting_app/widgets/custom_time_picker.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final supabase = Supabase.instance.client;
  final _imagePicker = ImagePicker();
  
  DateTime? _incidentDate;
  TimeOfDay? _incidentTime;
  String? _selectedCategory;
  bool _isAnonymous = false;
  File? _evidenceFile;
  bool _isLoading = false;
  String? _errorMessage;
  double _uploadProgress = 0.0;
  
  final List<String> _categories = [
    'Physical Harassment',
    'Verbal Harassment',
    'Psychological Harassment',
    'Sexual Harassment',
    'Cyber Harassment',
    'Other',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    
    if (image != null) {
      setState(() {
        _evidenceFile = File(image.path);
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_incidentDate == null) {
      setState(() {
        _errorMessage = 'Please select an incident date';
      });
      return;
    }
    
    if (_incidentTime == null) {
      setState(() {
        _errorMessage = 'Please select an incident time';
      });
      return;
    }
    
    if (_selectedCategory == null) {
      setState(() {
        _errorMessage = 'Please select a category';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final userId = supabase.auth.currentUser!.id;
      final complaintId = const Uuid().v4();
      final complaintNumber = 'RRS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      
      // Format date and time
      final formattedDate = DateFormat('yyyy-MM-dd').format(_incidentDate!);
      final formattedTime = '${_incidentTime!.hour.toString().padLeft(2, '0')}:${_incidentTime!.minute.toString().padLeft(2, '0')}:00';
      
      String? evidenceFileName;
      String? evidenceFilePath;
      String? evidenceFileType;
      
      // Upload evidence file if selected
      if (_evidenceFile != null) {
        final fileExtension = _evidenceFile!.path.split('.').last;
        final fileName = 'evidence_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
        evidenceFileName = fileName;
        evidenceFilePath = 'evidence/$userId/$fileName';
        evidenceFileType = _getFileType(fileExtension);
        
        // Upload file to Supabase Storage
        await supabase.storage.from('evidence').upload(
          evidenceFilePath,
          _evidenceFile!,
          onProgress: (bytesUploaded, totalBytes) {
            setState(() {
              _uploadProgress = bytesUploaded / totalBytes;
            });
          },
        );
      }
      
      // Insert complaint data
      await supabase.from('complaints').insert({
        'id': complaintId,
        'user_id': userId,
        'complaint_number': complaintNumber,
        'incident_date': formattedDate,
        'incident_time': formattedTime,
        'incident_location': _locationController.text.trim(),
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'anonymous': _isAnonymous,
        'status': 'Pending',
        'submission_date': DateTime.now().toIso8601String(),
        'evidence_path': evidenceFilePath,
        'evidence_file_name': evidenceFileName,
        'evidence_file_type': evidenceFileType,
      });
      
      if (!mounted) return;
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Report Submitted'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your report has been submitted successfully.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Complaint Number: $complaintNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please save this number for future reference.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to home
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to submit report: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  String? _getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Title
              const Text(
                'Report a Ragging Incident',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please provide details about the incident',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Incident date
              CustomDatePicker(
                label: 'Incident Date',
                selectedDate: _incidentDate,
                onDateSelected: (date) {
                  setState(() {
                    _incidentDate = date;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Incident time
              CustomTimePicker(
                label: 'Incident Time',
                selectedTime: _incidentTime,
                onTimeSelected: (time) {
                  setState(() {
                    _incidentTime = time;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Location
              CustomTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'Enter the incident location',
                prefixIcon: Icons.location_on_outlined,
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 16),
              
              // Category
              CustomDropdown(
                label: 'Category',
                hint: 'Select incident category',
                items: _categories,
                selectedValue: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe the incident in detail',
                maxLines: 5,
                prefixIcon: Icons.description_outlined,
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 16),
              
              // Evidence file
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Evidence (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Upload photos or documents as evidence',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // File preview
                      if (_evidenceFile != null) ...[
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _getFileType(_evidenceFile!.path.split('.').last)?.startsWith('image/')
                              ? Image.file(
                                  _evidenceFile!,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.insert_drive_file,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _evidenceFile!.path.split('/').last,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _evidenceFile = null;
                            });
                          },
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text(
                            'Remove File',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ] else ...[
                        InkWell(
                          onTap: _pickImage,
                          child: Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                                style: BorderStyle.dashed,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap to upload file',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      
                      // Upload progress
                      if (_isLoading && _evidenceFile != null && _uploadProgress > 0) ...[
                        const SizedBox(height: 16),
                        LinearProgressIndicator(value: _uploadProgress),
                        const SizedBox(height: 8),
                        Text(
                          'Uploading: ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Anonymous checkbox
              CheckboxListTile(
                title: const Text('Submit Anonymously'),
                subtitle: const Text(
                  'Your identity will be hidden from the public',
                  style: TextStyle(fontSize: 12),
                ),
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              
              // Submit button
              CustomButton(
                text: 'Submit Report',
                isLoading: _isLoading,
                onPressed: _submitReport,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}