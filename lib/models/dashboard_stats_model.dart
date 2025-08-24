import 'complaint_model.dart';

class DashboardStatsModel {
  final int totalComplaints;
  final int pendingComplaints;
  final int inProgressComplaints;
  final int resolvedComplaints;
  final int rejectedComplaints;
  final Map<ComplaintCategory, int> categoriesCount;
  final Map<Priority, int> prioritiesCount;
  final List<ComplaintModel> recentComplaints;
  final double resolutionRate;
  final double averageResolutionTime; // in days
  
  DashboardStatsModel({
    required this.totalComplaints,
    required this.pendingComplaints,
    required this.inProgressComplaints,
    required this.resolvedComplaints,
    required this.rejectedComplaints,
    required this.categoriesCount,
    required this.prioritiesCount,
    required this.recentComplaints,
    required this.resolutionRate,
    required this.averageResolutionTime,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalComplaints: json['total_complaints'] ?? 0,
      pendingComplaints: json['pending_complaints'] ?? 0,
      inProgressComplaints: json['in_progress_complaints'] ?? 0,
      resolvedComplaints: json['resolved_complaints'] ?? 0,
      rejectedComplaints: json['rejected_complaints'] ?? 0,
      categoriesCount: Map<ComplaintCategory, int>.from(
        json['categories_count']?.map((k, v) => MapEntry(
          ComplaintCategory.values.firstWhere(
            (e) => e.toString().split('.').last == k,
            orElse: () => ComplaintCategory.other,
          ),
          v as int,
        )) ?? {},
      ),
      prioritiesCount: Map<Priority, int>.from(
        json['priorities_count']?.map((k, v) => MapEntry(
          Priority.values.firstWhere(
            (e) => e.toString().split('.').last == k,
            orElse: () => Priority.medium,
          ),
          v as int,
        )) ?? {},
      ),
      recentComplaints: (json['recent_complaints'] as List?)
          ?.map((item) => ComplaintModel.fromJson(item))
          .toList() ?? [],
      resolutionRate: (json['resolution_rate'] ?? 0.0).toDouble(),
      averageResolutionTime: (json['average_resolution_time'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_complaints': totalComplaints,
      'pending_complaints': pendingComplaints,
      'in_progress_complaints': inProgressComplaints,
      'resolved_complaints': resolvedComplaints,
      'rejected_complaints': rejectedComplaints,
      'categories_count': categoriesCount.map(
        (k, v) => MapEntry(k.toString().split('.').last, v),
      ),
      'priorities_count': prioritiesCount.map(
        (k, v) => MapEntry(k.toString().split('.').last, v),
      ),
      'recent_complaints': recentComplaints.map((c) => c.toJson()).toList(),
      'resolution_rate': resolutionRate,
      'average_resolution_time': averageResolutionTime,
    };
  }
}
