import 'package:flutter/material.dart';
import 'package:ragging_reporting_app/widgets/custom_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final Map<String, dynamic> complaint;

  const ComplaintDetailScreen({
    Key? key,
    required this.complaint,
  }) : super(key: key);

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  final supabase = Supabase.instance.client;
  String? _evidenceUrl;
  bool _isLoadingEvidence = false;

  @override
  void initState() {
    super.initState();
    _getEvidenceUrl();
  }

  Future<void> _getEvidenceUrl() async {
    final evidencePath = widget.complaint['evidence_path'];
    if (evidencePath == null) return;
    
    setState(() {
      _isLoadingEvidence = true;
    });
    
    try {
      final url = await supabase.storage
          .from('evidence')
          .createSignedUrl(evidencePath, 60 * 60); // 1 hour expiry
      
      setState(() {
        _evidenceUrl = url;
      });
    } catch (e) {
      debugPrint('Error getting evidence URL: $e');
    } finally {
      setState(() {
        _isLoadingEvidence = false;
      });
    }
  }

  Future<void> _openEvidence() async {
    if (_evidenceUrl == null) return;
    
    final Uri url = Uri.parse(_evidenceUrl!);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_evidenceUrl');
    }
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'orange';
      case 'in progress':
        return 'blue';
      case 'resolved':
        return 'green';
      case 'rejected':
        return 'red';
      default:
        return 'grey';
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaint = widget.complaint;
    final incidentDate = DateFormat('yyyy-MM-dd').parse(complaint['incident_date']);
    final formattedDate = DateFormat('MMMM d, yyyy').format(incidentDate);
    final submissionDate = DateTime.parse(complaint['submission_date']);
    final formattedSubmissionDate = DateFormat('MMMM d, yyyy').format(submissionDate);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Complaint number and status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Complaint #${complaint['complaint_number']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildStatusBadge(complaint['status']),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Submitted on $formattedSubmissionDate',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Incident details
              const Text(
                'Incident Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Date', formattedDate),
                      _buildDetailRow('Time', complaint['incident_time']),
                      _buildDetailRow('Location', complaint['incident_location']),
                      _buildDetailRow('Category', complaint['category']),
                      const Divider(),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(complaint['description']),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Evidence
              if (complaint['evidence_path'] != null) ...[
                const Text(
                  'Evidence',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.attach_file),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                complaint['evidence_file_name'] ?? 'Evidence File',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _isLoadingEvidence
                            ? const Center(child: CircularProgressIndicator())
                            : _evidenceUrl != null
                                ? CustomButton(
                                    text: 'View Evidence',
                                    icon: Icons.visibility,
                                    onPressed: _openEvidence,
                                  )
                                : const Text(
                                    'Evidence file not available',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              
              // Public notes
              if (complaint['public_notes'] != null && complaint['public_notes'].toString().isNotEmpty) ...[
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(complaint['public_notes']),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    Color badgeColor;
    
    switch (color) {
      case 'green':
        badgeColor = Colors.green;
        break;
      case 'orange':
        badgeColor = Colors.orange;
        break;
      case 'blue':
        badgeColor = Colors.blue;
        break;
      case 'red':
        badgeColor = Colors.red;
        break;
      default:
        badgeColor = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}