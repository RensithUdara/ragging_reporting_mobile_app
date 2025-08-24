import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize authentication state
  Future<void> initAuth() async {
    _setLoading(true);
    
    try {
      _isAuthenticated = _authService.isAuthenticated;
      
      if (_isAuthenticated) {
        await _loadUserProfile();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? institution,
    String? studentId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        institution: institution,
        studentId: studentId,
      );

      if (response.user != null) {
        _isAuthenticated = true;
        await _loadUserProfile();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(_parseAuthError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _isAuthenticated = true;
        await _loadUserProfile();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(_parseAuthError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _authService.signOut();
      await StorageService.clearAllData();
      
      _currentUser = null;
      _isAuthenticated = false;
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(_parseAuthError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update password
  Future<bool> updatePassword(String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updatePassword(newPassword);
      return true;
    } catch (e) {
      _setError(_parseAuthError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update email
  Future<bool> updateEmail(String newEmail) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updateEmail(newEmail);
      await _loadUserProfile(); // Reload profile with new email
      return true;
    } catch (e) {
      _setError(_parseAuthError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updateUserProfile(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Resend email verification
  Future<bool> resendEmailVerification() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resendEmailVerification();
      return true;
    } catch (e) {
      _setError(_parseAuthError(e.toString()));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.deleteAccount();
      await StorageService.clearAllData();
      
      _currentUser = null;
      _isAuthenticated = false;
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Private methods
  Future<void> _loadUserProfile() async {
    try {
      _currentUser = await _authService.getUserProfile();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load user profile: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
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

  String _parseAuthError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    } else if (error.contains('Email not confirmed')) {
      return 'Please verify your email address before signing in.';
    } else if (error.contains('User already registered')) {
      return 'An account with this email already exists.';
    } else if (error.contains('Password should be at least 6 characters')) {
      return 'Password must be at least 6 characters long.';
    } else if (error.contains('Unable to validate email address')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('Network request failed')) {
      return AppConstants.networkError;
    }
    
    return AppConstants.unknownError;
  }

  // Clear error message
  void clearError() {
    _clearError();
  }

  // Check if user is admin
  bool get isAdmin => _currentUser?.role == AppConstants.adminRole;

  // Check if user is moderator
  bool get isModerator => _currentUser?.role == AppConstants.moderatorRole;

  // Get user's display name
  String get displayName => _currentUser?.fullName ?? 'User';

  // Get user's initials for avatar
  String get userInitials {
    if (_currentUser?.fullName != null) {
      final names = _currentUser!.fullName.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else if (names.isNotEmpty) {
        return names[0][0].toUpperCase();
      }
    }
    return 'U';
  }
}
