import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/complaint_model.dart';
import '../models/dashboard_stats_model.dart';
import '../constants/app_constants.dart';

class ComplaintService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Submit a new complaint
  Future<ComplaintModel> submitComplaint({
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
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final complaintId = _generateComplaintId();
      final complaintNumber = _generateComplaintNumber();

      String? evidencePath;
      String? evidenceFileName;
      String? evidenceFileType;

      // Upload evidence file if provided
      if (evidenceFile != null) {
        final fileExtension = evidenceFile.path.split('.').last;
        evidenceFileName = 'evidence_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
        evidencePath = 'evidence/$userId/$evidenceFileName';
        evidenceFileType = _getFileType(fileExtension);

        await _supabase.storage
            .from(AppConstants.evidenceBucket)
            .upload(evidencePath, evidenceFile);
      }

      final complaint = ComplaintModel(
        id: complaintId,
        userId: userId,
        complaintNumber: complaintNumber,
        incidentDate: incidentDate,
        incidentTime: incidentTime,
        incidentLocation: incidentLocation,
        category: category,
        description: description,
        isAnonymous: isAnonymous,
        status: ComplaintStatus.pending,
        priority: priority,
        submissionDate: DateTime.now(),
        evidencePath: evidencePath,
        evidenceFileName: evidenceFileName,
        evidenceFileType: evidenceFileType,
        witnesses: witnesses,
      );

      await _supabase.from('complaints').insert(complaint.toJson());

      return complaint;
    } catch (e) {
      throw Exception('Failed to submit complaint: ${e.toString()}');
    }
  }

  // Get complaint by complaint number
  Future<ComplaintModel?> getComplaintByNumber(String complaintNumber) async {
    try {
      final response = await _supabase
          .from('complaints')
          .select()
          .eq('complaint_number', complaintNumber)
          .single();

      return ComplaintModel.fromJson(response);
    } catch (e) {
      throw Exception('Complaint not found');
    }
  }

  // Get complaint by ID
  Future<ComplaintModel?> getComplaintById(String complaintId) async {
    try {
      final response = await _supabase
          .from('complaints')
          .select()
          .eq('id', complaintId)
          .single();

      return ComplaintModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get complaint: ${e.toString()}');
    }
  }

  // Get user's complaints
  Future<List<ComplaintModel>> getUserComplaints({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final from = (page - 1) * limit;
      final to = from + limit - 1;

      final response = await _supabase
          .from('complaints')
          .select()
          .eq('user_id', userId)
          .order('submission_date', ascending: false)
          .range(from, to);

      return (response as List)
          .map((item) => ComplaintModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user complaints: ${e.toString()}');
    }
  }

  // Get all complaints (for admin)
  Future<List<ComplaintModel>> getAllComplaints({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
    ComplaintStatus? status,
    ComplaintCategory? category,
    String? searchQuery,
  }) async {
    try {
      var queryBuilder = _supabase
          .from('complaints')
          .select();

      // Apply filters
      if (status != null) {
        queryBuilder = queryBuilder.eq('status', ComplaintModel.statusToString(status));
      }

      if (category != null) {
        queryBuilder = queryBuilder.eq('category', ComplaintModel.categoryToString(category));
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryBuilder = queryBuilder.or('description.ilike.%$searchQuery%,incident_location.ilike.%$searchQuery%');
      }

      final from = (page - 1) * limit;
      final to = from + limit - 1;

      final response = await queryBuilder
          .order('submission_date', ascending: false)
          .range(from, to);

      return (response as List)
          .map((item) => ComplaintModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get complaints: ${e.toString()}');
    }
  }

  // Update complaint status (admin only)
  Future<void> updateComplaintStatus({
    required String complaintId,
    required ComplaintStatus status,
    String? publicNotes,
    String? adminNotes,
    String? resolutionNotes,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': ComplaintModel.statusToString(status),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (publicNotes != null) updateData['public_notes'] = publicNotes;
      if (adminNotes != null) updateData['admin_notes'] = adminNotes;
      if (resolutionNotes != null) updateData['resolution_notes'] = resolutionNotes;

      if (status == ComplaintStatus.resolved || status == ComplaintStatus.closed) {
        updateData['resolved_at'] = DateTime.now().toIso8601String();
      }

      await _supabase
          .from('complaints')
          .update(updateData)
          .eq('id', complaintId);
    } catch (e) {
      throw Exception('Failed to update complaint status: ${e.toString()}');
    }
  }

  // Get dashboard statistics
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Get user's complaints count by status
      final userComplaints = await _supabase
          .from('complaints')
          .select('status')
          .eq('user_id', userId);

      final totalComplaints = userComplaints.length;
      final pendingComplaints = userComplaints.where((c) => c['status'] == 'Pending').length;
      final inProgressComplaints = userComplaints.where((c) => c['status'] == 'In Progress').length;
      final resolvedComplaints = userComplaints.where((c) => c['status'] == 'Resolved').length;
      final rejectedComplaints = userComplaints.where((c) => c['status'] == 'Rejected').length;

      // Get recent complaints
      final recentComplaintsData = await _supabase
          .from('complaints')
          .select()
          .eq('user_id', userId)
          .order('submission_date', ascending: false)
          .limit(5);

      final recentComplaints = (recentComplaintsData as List)
          .map((item) => ComplaintModel.fromJson(item))
          .toList();

      // Calculate resolution rate
      final resolvedCount = resolvedComplaints + rejectedComplaints;
      final resolutionRate = totalComplaints > 0 ? (resolvedCount / totalComplaints) * 100 : 0.0;

      return DashboardStatsModel(
        totalComplaints: totalComplaints,
        pendingComplaints: pendingComplaints,
        inProgressComplaints: inProgressComplaints,
        resolvedComplaints: resolvedComplaints,
        rejectedComplaints: rejectedComplaints,
        categoriesCount: {}, // Would need separate query for this
        prioritiesCount: {}, // Would need separate query for this
        recentComplaints: recentComplaints,
        resolutionRate: resolutionRate,
        averageResolutionTime: 0.0, // Would need calculation based on resolved complaints
      );
    } catch (e) {
      throw Exception('Failed to get dashboard stats: ${e.toString()}');
    }
  }

  // Get evidence file URL
  Future<String> getEvidenceUrl(String evidencePath) async {
    try {
      return await _supabase.storage
          .from(AppConstants.evidenceBucket)
          .createSignedUrl(evidencePath, 3600); // 1 hour expiry
    } catch (e) {
      throw Exception('Failed to get evidence URL: ${e.toString()}');
    }
  }

  // Delete complaint (soft delete)
  Future<void> deleteComplaint(String complaintId) async {
    try {
      await _supabase
          .from('complaints')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', complaintId);
    } catch (e) {
      throw Exception('Failed to delete complaint: ${e.toString()}');
    }
  }

  // Helper methods
  String _generateComplaintId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _generateComplaintNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return 'RRS-${timestamp.substring(timestamp.length - 8)}';
  }

  String _getFileType(String extension) {
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
}
