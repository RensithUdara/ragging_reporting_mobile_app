import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;
  
  // Get auth stream
  Stream<AuthState> get authStateStream => _supabase.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? institution,
    String? studentId,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile
        await _supabase.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'institution': institution,
          'student_id': studentId,
          'role': AppConstants.userRole,
          'email_verified': false,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      return response;
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      return await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Password update failed: ${e.toString()}');
    }
  }

  // Update email
  Future<UserResponse> updateEmail(String newEmail) async {
    try {
      return await _supabase.auth.updateUser(
        UserAttributes(email: newEmail),
      );
    } catch (e) {
      throw Exception('Email update failed: ${e.toString()}');
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _supabase
          .from('users')
          .update(user.toJson())
          .eq('id', user.id);
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Verify email
  Future<void> resendEmailVerification() async {
    try {
      final user = currentUser;
      if (user?.email != null) {
        await _supabase.auth.resend(
          type: OtpType.signup,
          email: user!.email!,
        );
      }
    } catch (e) {
      throw Exception('Failed to resend verification email: ${e.toString()}');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final userId = currentUser?.id;
      if (userId != null) {
        // Delete user profile
        await _supabase.from('users').delete().eq('id', userId);
        
        // Sign out
        await signOut();
      }
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }
}
