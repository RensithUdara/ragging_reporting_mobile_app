import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthController>(
        builder: (context, authController, child) {
          final user = authController.currentUser;
          
          if (user == null) {
            return const Center(
              child: Text('User not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          authController.userInitials,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Profile Information
                _buildInfoCard([
                  _buildInfoTile(Icons.person, 'Full Name', user.fullName),
                  _buildInfoTile(Icons.email, 'Email', user.email),
                  if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                    _buildInfoTile(Icons.phone, 'Phone', user.phoneNumber!),
                  if (user.studentId != null && user.studentId!.isNotEmpty)
                    _buildInfoTile(Icons.badge, 'Student ID', user.studentId!),
                  if (user.institution != null && user.institution!.isNotEmpty)
                    _buildInfoTile(Icons.school, 'Institution', user.institution!),
                ]),
                const SizedBox(height: 24),

                // Account Actions
                _buildInfoCard([
                  ListTile(
                    leading: const Icon(Icons.edit, color: AppTheme.primaryColor),
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showEditProfile(context, user);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock, color: AppTheme.primaryColor),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showChangePassword(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications, color: AppTheme.primaryColor),
                    title: const Text('Notification Settings'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showNotificationSettings(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help, color: AppTheme.primaryColor),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showHelpSupport(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info, color: AppTheme.primaryColor),
                    title: const Text('About'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showAbout(context);
                    },
                  ),
                ]),
                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Logout',
                    onPressed: () => _handleLogout(context, authController),
                  ),
                ),
                const SizedBox(height: 16),

                // App Version
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  void _handleLogout(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authController.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Profile editing feature will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text('Password change feature will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Text('Notification settings will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text('For support, please contact us at support@raggingapp.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Ragging Reporting App',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Ragging Reporting Team',
      children: [
        const Text('A safe platform for reporting ragging incidents anonymously.'),
      ],
    );
  }
}
