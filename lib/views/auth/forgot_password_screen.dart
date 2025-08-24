import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Icon
                const Icon(
                  Icons.lock_reset_rounded,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                
                // Title and Description
                Text(
                  _isEmailSent ? 'Check Your Email' : 'Reset Password',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                Text(
                  _isEmailSent
                      ? 'We\'ve sent a password reset link to your email address'
                      : 'Enter your email address and we\'ll send you a link to reset your password',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Reset Form Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: _isEmailSent ? _buildEmailSentContent() : _buildResetForm(),
                ),
                
                const Spacer(),
                
                // Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Remember your password? ',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          label: 'Email Address',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 32),
        
        Consumer<AuthController>(
          builder: (context, authController, child) {
            return CustomButton(
              text: 'Send Reset Link',
              onPressed: authController.isLoading ? null : _handleResetPassword,
              isLoading: authController.isLoading,
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmailSentContent() {
    return Column(
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 64,
          color: AppTheme.primaryColor,
        ),
        
        const SizedBox(height: 24),
        
        const Text(
          'Email Sent Successfully!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'We\'ve sent a password reset link to\n${_emailController.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        
        const SizedBox(height: 32),
        
        CustomButton(
          text: 'Resend Email',
          onPressed: _handleResetPassword,
          isOutlined: true,
        ),
        
        const SizedBox(height: 16),
        
        CustomButton(
          text: 'Back to Login',
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authController = Provider.of<AuthController>(context, listen: false);
      
      try {
        await authController.resetPassword(_emailController.text.trim());
        
        setState(() {
          _isEmailSent = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset email sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send reset email: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
