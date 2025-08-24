import 'package:flutter/material.dart';
import 'dart:io';
import '../models/complaint_model.dart';
import '../models/dashboard_stats_model.dart';
import '../services/complaint_service.dart';
import '../constants/app_constants.dart';

class ComplaintController extends ChangeNotifier {
  final ComplaintService _complaintService = ComplaintService();
  
  List<ComplaintModel> _complaints = [];
  ComplaintModel? _selectedComplaint;
  DashboardStatsModel? _dashboardStats;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSubmitting = false;

  // Getters
  List<ComplaintModel> get complaints => _complaints;
  ComplaintModel? get selectedComplaint => _selectedComplaint;
  DashboardStatsModel? get dashboardStats => _dashboardStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;

  // Submit complaint
  Future<bool> submitComplaint({
    required String incidentLocation,
    required DateTime incidentDate,
    required String incidentTime,
    required ComplaintCategory category,
    required String description,
    bool isAnonymous = false,
    File? evidenceFile,
    List<String>? witnesses,
    Priority priority = Priority.medium,
  }) async {
    _setSubmitting(true);
    _clearError();

    try {
      final complaint = await _complaintService.submitComplaint(
        incidentLocation: incidentLocation,
        incidentDate: incidentDate,
        incidentTime: incidentTime,
        category: category,
        description: description,
        isAnonymous: isAnonymous,
        evidenceFile: evidenceFile,
        witnesses: witnesses,
        priority: priority,
      );

      // Add to local list
      _complaints.insert(0, complaint);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  // Get complaint by number
  Future<bool> getComplaintByNumber(String complaintNumber) async {
    _setLoading(true);
    _clearError();

    try {
      final complaint = await _complaintService.getComplaintByNumber(complaintNumber);
      
      if (complaint != null) {
        _selectedComplaint = complaint;
        notifyListeners();
        return true;
      }
      
      _setError('Complaint not found');
      return false;
    } catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get complaint by ID
  Future<bool> getComplaintById(String complaintId) async {
    _setLoading(true);
    _clearError();

    try {
      final complaint = await _complaintService.getComplaintById(complaintId);
      
      if (complaint != null) {
        _selectedComplaint = complaint;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(_parseError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load user complaints
  Future<void> loadUserComplaints({
    int page = 1,
    bool refresh = false,
  }) async {
    if (!refresh && _isLoading) return;
    
    _setLoading(true);
    if (refresh) _clearError();

    try {
      final newComplaints = await _complaintService.getUserComplaints(
        page: page,
        limit: AppConstants.defaultPageSize,
      );

      if (refresh || page == 1) {
        _complaints = newComplaints;
      } else {
        _complaints.addAll(newComplaints);
      }

      notifyListeners();
    } catch (e) {
      _setError(_parseError(e.toString()));
    } finally {
      _setLoading(false);
    }
  }

  // Load dashboard stats
  Future<void> loadDashboardStats() async {
    _setLoading(true);
    _clearError();

    try {
      _dashboardStats = await _complaintService.getDashboardStats();
      notifyListeners();
    } catch (e) {
      _setError(_parseError(e.toString()));
    } finally {
      _setLoading(false);
    }
  }

  // Get evidence URL
  Future<String?> getEvidenceUrl(String evidencePath) async {
    try {
      return await _complaintService.getEvidenceUrl(evidencePath);
    } catch (e) {
      debugPrint('Failed to get evidence URL: $e');
      return null;
    }
  }

  // Filter complaints by status
  List<ComplaintModel> getComplaintsByStatus(ComplaintStatus status) {
    return _complaints.where((complaint) => complaint.status == status).toList();
  }

  // Filter complaints by category
  List<ComplaintModel> getComplaintsByCategory(ComplaintCategory category) {
    return _complaints.where((complaint) => complaint.category == category).toList();
  }

  // Get complaints count by status
  int getComplaintsCountByStatus(ComplaintStatus status) {
    return _complaints.where((complaint) => complaint.status == status).length;
  }

  // Search complaints
  List<ComplaintModel> searchComplaints(String query) {
    if (query.isEmpty) return _complaints;
    
    final lowerQuery = query.toLowerCase();
    return _complaints.where((complaint) {
      return complaint.description.toLowerCase().contains(lowerQuery) ||
             complaint.incidentLocation.toLowerCase().contains(lowerQuery) ||
             complaint.complaintNumber.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get recent complaints (last 30 days)
  List<ComplaintModel> getRecentComplaints() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _complaints
        .where((complaint) => complaint.submissionDate.isAfter(thirtyDaysAgo))
        .toList();
  }

  // Get complaints by priority
  List<ComplaintModel> getComplaintsByPriority(Priority priority) {
    return _complaints.where((complaint) => complaint.priority == priority).toList();
  }

  // Get complaints summary
  Map<String, int> getComplaintsSummary() {
    return {
      'total': _complaints.length,
      'pending': getComplaintsCountByStatus(ComplaintStatus.pending),
      'in_progress': getComplaintsCountByStatus(ComplaintStatus.inProgress),
      'resolved': getComplaintsCountByStatus(ComplaintStatus.resolved),
      'rejected': getComplaintsCountByStatus(ComplaintStatus.rejected),
    };
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _parseError(String error) {
    if (error.contains('Network')) {
      return AppConstants.networkError;
    } else if (error.contains('Server')) {
      return AppConstants.serverError;
    } else if (error.contains('Authentication')) {
      return AppConstants.authenticationError;
    } else if (error.contains('Permission')) {
      return AppConstants.permissionError;
    }
    
    return error.contains('Failed to') ? error : AppConstants.unknownError;
  }

  // Clear error message
  void clearError() {
    _clearError();
  }

  // Clear selected complaint
  void clearSelectedComplaint() {
    _selectedComplaint = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadUserComplaints(refresh: true),
      loadDashboardStats(),
    ]);
  }

  // Check if complaint can be edited (only pending complaints)
  bool canEditComplaint(ComplaintModel complaint) {
    return complaint.status == ComplaintStatus.pending;
  }

  // Check if complaint has evidence
  bool hasEvidence(ComplaintModel complaint) {
    return complaint.evidencePath != null && complaint.evidencePath!.isNotEmpty;
  }

  // Get status color
  Color getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending:
        return Color(AppConstants.statusColors['pending']!);
      case ComplaintStatus.inProgress:
        return Color(AppConstants.statusColors['in_progress']!);
      case ComplaintStatus.resolved:
        return Color(AppConstants.statusColors['resolved']!);
      case ComplaintStatus.rejected:
        return Color(AppConstants.statusColors['rejected']!);
      case ComplaintStatus.closed:
        return Color(AppConstants.statusColors['closed']!);
    }
  }

  // Get priority color
  Color getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Color(AppConstants.priorityColors['low']!);
      case Priority.medium:
        return Color(AppConstants.priorityColors['medium']!);
      case Priority.high:
        return Color(AppConstants.priorityColors['high']!);
      case Priority.critical:
        return Color(AppConstants.priorityColors['critical']!);
    }
  }
}
