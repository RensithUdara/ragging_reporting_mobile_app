enum ComplaintStatus {
  pending,
  inProgress,
  resolved,
  rejected,
  closed
}

enum ComplaintCategory {
  physicalHarassment,
  verbalHarassment,
  psychologicalHarassment,
  sexualHarassment,
  cyberHarassment,
  discrimination,
  bullying,
  other
}

enum Priority {
  low,
  medium,
  high,
  critical
}

class ComplaintModel {
  final String id;
  final String userId;
  final String complaintNumber;
  final DateTime incidentDate;
  final String incidentTime;
  final String incidentLocation;
  final ComplaintCategory category;
  final String description;
  final bool isAnonymous;
  final ComplaintStatus status;
  final Priority priority;
  final DateTime submissionDate;
  final String? evidencePath;
  final String? evidenceFileName;
  final String? evidenceFileType;
  final String? publicNotes;
  final String? adminNotes;
  final String? assignedTo;
  final DateTime? resolvedAt;
  final String? resolutionNotes;
  final List<String>? witnesses;
  final Map<String, dynamic>? metadata;

  ComplaintModel({
    required this.id,
    required this.userId,
    required this.complaintNumber,
    required this.incidentDate,
    required this.incidentTime,
    required this.incidentLocation,
    required this.category,
    required this.description,
    this.isAnonymous = false,
    this.status = ComplaintStatus.pending,
    this.priority = Priority.medium,
    required this.submissionDate,
    this.evidencePath,
    this.evidenceFileName,
    this.evidenceFileType,
    this.publicNotes,
    this.adminNotes,
    this.assignedTo,
    this.resolvedAt,
    this.resolutionNotes,
    this.witnesses,
    this.metadata,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      complaintNumber: json['complaint_number'] ?? '',
      incidentDate: DateTime.parse(json['incident_date']),
      incidentTime: json['incident_time'] ?? '',
      incidentLocation: json['incident_location'] ?? '',
      category: _parseCategory(json['category']),
      description: json['description'] ?? '',
      isAnonymous: json['anonymous'] ?? false,
      status: _parseStatus(json['status']),
      priority: _parsePriority(json['priority'] ?? 'medium'),
      submissionDate: DateTime.parse(json['submission_date'] ?? DateTime.now().toIso8601String()),
      evidencePath: json['evidence_path'],
      evidenceFileName: json['evidence_file_name'],
      evidenceFileType: json['evidence_file_type'],
      publicNotes: json['public_notes'],
      adminNotes: json['admin_notes'],
      assignedTo: json['assigned_to'],
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at']) : null,
      resolutionNotes: json['resolution_notes'],
      witnesses: json['witnesses'] != null ? List<String>.from(json['witnesses']) : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'complaint_number': complaintNumber,
      'incident_date': incidentDate.toIso8601String().split('T')[0],
      'incident_time': incidentTime,
      'incident_location': incidentLocation,
      'category': categoryToString(category),
      'description': description,
      'anonymous': isAnonymous,
      'status': statusToString(status),
      'priority': priorityToString(priority),
      'submission_date': submissionDate.toIso8601String(),
      'evidence_path': evidencePath,
      'evidence_file_name': evidenceFileName,
      'evidence_file_type': evidenceFileType,
      'public_notes': publicNotes,
      'admin_notes': adminNotes,
      'assigned_to': assignedTo,
      'resolved_at': resolvedAt?.toIso8601String(),
      'resolution_notes': resolutionNotes,
      'witnesses': witnesses,
      'metadata': metadata,
    };
  }

  static ComplaintCategory _parseCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'physical harassment':
        return ComplaintCategory.physicalHarassment;
      case 'verbal harassment':
        return ComplaintCategory.verbalHarassment;
      case 'psychological harassment':
        return ComplaintCategory.psychologicalHarassment;
      case 'sexual harassment':
        return ComplaintCategory.sexualHarassment;
      case 'cyber harassment':
        return ComplaintCategory.cyberHarassment;
      case 'discrimination':
        return ComplaintCategory.discrimination;
      case 'bullying':
        return ComplaintCategory.bullying;
      default:
        return ComplaintCategory.other;
    }
  }

  static ComplaintStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return ComplaintStatus.pending;
      case 'in progress':
        return ComplaintStatus.inProgress;
      case 'resolved':
        return ComplaintStatus.resolved;
      case 'rejected':
        return ComplaintStatus.rejected;
      case 'closed':
        return ComplaintStatus.closed;
      default:
        return ComplaintStatus.pending;
    }
  }

  static Priority _parsePriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'medium':
        return Priority.medium;
      case 'high':
        return Priority.high;
      case 'critical':
        return Priority.critical;
      default:
        return Priority.medium;
    }
  }

  static String categoryToString(ComplaintCategory category) {
    switch (category) {
      case ComplaintCategory.physicalHarassment:
        return 'Physical Harassment';
      case ComplaintCategory.verbalHarassment:
        return 'Verbal Harassment';
      case ComplaintCategory.psychologicalHarassment:
        return 'Psychological Harassment';
      case ComplaintCategory.sexualHarassment:
        return 'Sexual Harassment';
      case ComplaintCategory.cyberHarassment:
        return 'Cyber Harassment';
      case ComplaintCategory.discrimination:
        return 'Discrimination';
      case ComplaintCategory.bullying:
        return 'Bullying';
      case ComplaintCategory.other:
        return 'Other';
    }
  }

  static String statusToString(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending:
        return 'Pending';
      case ComplaintStatus.inProgress:
        return 'In Progress';
      case ComplaintStatus.resolved:
        return 'Resolved';
      case ComplaintStatus.rejected:
        return 'Rejected';
      case ComplaintStatus.closed:
        return 'Closed';
    }
  }

  static String priorityToString(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.critical:
        return 'Critical';
    }
  }

  ComplaintModel copyWith({
    String? id,
    String? userId,
    String? complaintNumber,
    DateTime? incidentDate,
    String? incidentTime,
    String? incidentLocation,
    ComplaintCategory? category,
    String? description,
    bool? isAnonymous,
    ComplaintStatus? status,
    Priority? priority,
    DateTime? submissionDate,
    String? evidencePath,
    String? evidenceFileName,
    String? evidenceFileType,
    String? publicNotes,
    String? adminNotes,
    String? assignedTo,
    DateTime? resolvedAt,
    String? resolutionNotes,
    List<String>? witnesses,
    Map<String, dynamic>? metadata,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      complaintNumber: complaintNumber ?? this.complaintNumber,
      incidentDate: incidentDate ?? this.incidentDate,
      incidentTime: incidentTime ?? this.incidentTime,
      incidentLocation: incidentLocation ?? this.incidentLocation,
      category: category ?? this.category,
      description: description ?? this.description,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      submissionDate: submissionDate ?? this.submissionDate,
      evidencePath: evidencePath ?? this.evidencePath,
      evidenceFileName: evidenceFileName ?? this.evidenceFileName,
      evidenceFileType: evidenceFileType ?? this.evidenceFileType,
      publicNotes: publicNotes ?? this.publicNotes,
      adminNotes: adminNotes ?? this.adminNotes,
      assignedTo: assignedTo ?? this.assignedTo,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      witnesses: witnesses ?? this.witnesses,
      metadata: metadata ?? this.metadata,
    );
  }
}
