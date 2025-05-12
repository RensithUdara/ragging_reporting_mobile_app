import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ragging_reporting_app/utils/validators.dart';
import 'package:ragging_reporting_app/widgets/custom_button.dart';
import 'package:ragging_reporting_app/widgets/custom_text_field.dart';
import 'package:ragging_reporting_app/screens/complaint_detail_screen.dart';

class CheckStatusScreen extends StatefulWidget {
  const CheckStatusScreen({Key? key}) : super(key: key);

  @override
  State<CheckStatusScreen> createState() => _CheckStatusScreenState();
}

class _CheckStatusScreenState extends State<CheckStatusScreen> {
  final _formKey = GlobalKey<FormState>();
  final _complaintNumberController = TextEditingController();
  final supabase = Supabase.instance.client;
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _complaintNumberController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final complaintNumber = _complaintNumberController.text.trim();
      
      // Query the complaint
      final response = await supabase
          .from('complaints')
          .select('*')
          .eq('complaint_number', complaintNumber)
          .single();
      
      if (!mounted) return;
      
      // Navigate to complaint detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ComplaintDetailScreen(complaint: response),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Complaint not found. Please check the number and try again.';
      });
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
        title: const Text('Check Status'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                const Text(
                  'Check Complaint Status',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your complaint number to check its status',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
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
                
                // Complaint number field
                CustomTextField(
                  controller: _complaintNumberController,
                  label: 'Complaint Number',
                  hint: 'Enter your complaint number (e.g., RRS-12345678)',
                  prefixIcon: Icons.numbers,
                  validator: Validators.validateComplaintNumber,
                ),
                const SizedBox(height: 24),
                
                // Check status button
                CustomButton(
                  text: 'Check Status',
                  isLoading: _isLoading,
                  onPressed: _checkStatus,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}