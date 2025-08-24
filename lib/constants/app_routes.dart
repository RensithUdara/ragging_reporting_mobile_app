import 'package:flutter/material.dart';

class AppRoutes {
  // Authentication Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String resetPassword = '/reset-password';
  
  // Main App Routes
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  
  // Complaint Routes
  static const String reportIncident = '/report-incident';
  static const String checkStatus = '/check-status';
  static const String complaintDetails = '/complaint-details';
  static const String myComplaints = '/my-complaints';
  static const String complaintHistory = '/complaint-history';
  
  // Information Routes
  static const String about = '/about';
  static const String faq = '/faq';
  static const String contact = '/contact';
  static const String emergencyContacts = '/emergency-contacts';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';
  
  // Admin Routes (if applicable)
  static const String adminDashboard = '/admin/dashboard';
  static const String adminComplaints = '/admin/complaints';
  static const String adminUsers = '/admin/users';
  static const String adminReports = '/admin/reports';
  
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Note: Actual route implementations would be added here
      // This is a placeholder structure
    };
  }
  
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Handle dynamic routes here
      default:
        return null;
    }
  }
  
  // Navigation helpers
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, login, (route) => false);
  }
  
  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, home, (route) => false);
  }
  
  static void navigateToComplaintDetails(BuildContext context, String complaintId) {
    Navigator.pushNamed(
      context, 
      complaintDetails, 
      arguments: {'complaintId': complaintId},
    );
  }
  
  static void navigateBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
  
  static void navigateAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }
  
  static void navigateAndClearStack(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context, 
      routeName, 
      (route) => false,
      arguments: arguments,
    );
  }
}
