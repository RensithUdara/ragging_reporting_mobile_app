class AppConstants {
  // App Information
  static const String appName = 'Sri Lankan Ragging Reporting System';
  static const String appVersion = '1.0.0';
  
  // API Endpoints (if needed for external services)
  static const String baseUrl = 'https://api.raggingportal.lk';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_preference';
  static const String languageKey = 'language_preference';
  static const String notificationKey = 'notification_enabled';
  
  // Supabase Storage Buckets
  static const String evidenceBucket = 'evidence';
  static const String profilePicturesBucket = 'profile-pictures';
  static const String documentsBucket = 'documents';
  
  // File Upload Limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt'];
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Time Constants
  static const int defaultTimeout = 30; // seconds
  static const int cacheExpiration = 3600; // 1 hour in seconds
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int maxDescriptionLength = 2000;
  static const int maxNameLength = 100;
  
  // Status Colors (Material Colors)
  static const Map<String, int> statusColors = {
    'pending': 0xFFFF9800, // Orange
    'in_progress': 0xFF2196F3, // Blue
    'resolved': 0xFF4CAF50, // Green
    'rejected': 0xFFF44336, // Red
    'closed': 0xFF9E9E9E, // Grey
  };
  
  // Priority Colors
  static const Map<String, int> priorityColors = {
    'low': 0xFF4CAF50, // Green
    'medium': 0xFFFF9800, // Orange
    'high': 0xFFFF5722, // Deep Orange
    'critical': 0xFFF44336, // Red
  };
  
  // Complaint Categories
  static const List<String> complaintCategories = [
    'Physical Harassment',
    'Verbal Harassment',
    'Psychological Harassment',
    'Sexual Harassment',
    'Cyber Harassment',
    'Discrimination',
    'Bullying',
    'Other',
  ];
  
  // User Roles
  static const String userRole = 'user';
  static const String adminRole = 'admin';
  static const String moderatorRole = 'moderator';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 1000);
  
  // Network
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  
  // Error Messages
  static const String networkError = 'Network connection error. Please check your internet connection.';
  static const String serverError = 'Server error occurred. Please try again later.';
  static const String unknownError = 'An unexpected error occurred. Please try again.';
  static const String authenticationError = 'Authentication failed. Please login again.';
  static const String permissionError = 'You do not have permission to perform this action.';
  static const String validationError = 'Please check your input and try again.';
  static const String fileUploadError = 'Failed to upload file. Please try again.';
  
  // Success Messages
  static const String complaintSubmitted = 'Your complaint has been submitted successfully.';
  static const String profileUpdated = 'Profile updated successfully.';
  static const String passwordChanged = 'Password changed successfully.';
  static const String notificationMarkedRead = 'Notification marked as read.';
  
  // Emergency Contacts
  static const List<Map<String, String>> emergencyContacts = [
    {
      'name': 'Police Emergency',
      'number': '119',
      'type': 'emergency'
    },
    {
      'name': 'University Counseling',
      'number': '+94-11-2345678',
      'type': 'counseling'
    },
    {
      'name': 'Student Affairs',
      'number': '+94-11-2345679',
      'type': 'administration'
    },
  ];
  
  // Help URLs
  static const String faqUrl = 'https://raggingportal.lk/faq';
  static const String supportUrl = 'https://raggingportal.lk/support';
  static const String privacyPolicyUrl = 'https://raggingportal.lk/privacy';
  static const String termsOfServiceUrl = 'https://raggingportal.lk/terms';
  
  // Regex Patterns
  static const String emailPattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+$';
  static const String phonePattern = r'^[+]?[0-9]{10,15}$';
  static const String complaintNumberPattern = r'^RRS-[0-9]{8,10}$';
}
