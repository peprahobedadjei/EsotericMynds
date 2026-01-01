import 'package:deepthinkers/screens/chat_rooms_screen.dart';
import 'package:deepthinkers/screens/theme_selector_screen.dart';
import 'package:deepthinkers/screens/update_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/post_provider.dart';
import '../services/profile_service.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  void _showRooms(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatRoomsScreen()),
    );
  }

  void _showThemeSelector(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ThemeSelectorScreen()),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          title: Text(
            'Delete Account',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: GoogleFonts.montserrat(
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(color: AppColors.greyText),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Delete',
                style: GoogleFonts.montserrat(
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.deleteAccount();

      if (context.mounted) {
        if (success) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Failed to delete account',        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 60.r,
              backgroundColor: themeProvider.primaryColor,
              backgroundImage: authProvider.currentUser?.profilePictureUrl != null &&
                      authProvider.currentUser!.profilePictureUrl!.isNotEmpty
                  ? NetworkImage(authProvider.currentUser!.profilePictureUrl!)
                  : null,
              child: authProvider.currentUser?.profilePictureUrl == null ||
                      authProvider.currentUser!.profilePictureUrl!.isEmpty
                  ? Text(
                      (authProvider.currentUser?.username ?? 'U')[0].toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),

            SizedBox(height: 16.h),

            // Name
            Text(
              authProvider.currentUser?.name ?? 'User',
              style: GoogleFonts.montserrat(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),

            SizedBox(height: 4.h),

            // Username
            Text(
              '@${authProvider.currentUser?.username ?? "username"}',
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                color: AppColors.greyText,
              ),
            ),

            SizedBox(height: 8.h),

            // Email
            Text(
              authProvider.currentUser?.email ?? 'email@example.com',
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                color: AppColors.greyText,
              ),
            ),

            if (authProvider.currentUser?.bio != null &&
                authProvider.currentUser!.bio.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  authProvider.currentUser!.bio,
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            SizedBox(height: 32.h),

            // Menu Options
            _buildMenuTile(
              context,
              icon: Iconsax.edit,
              title: 'Update Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UpdateProfileScreen()),
                );
              },
            ),

            _buildMenuTile(
              context,
              icon: Iconsax.messages,
              title: 'Chat Rooms',
              onTap: () => _showRooms(context),
            ),

            _buildMenuTile(
              context,
              icon: Iconsax.color_swatch,
              title: 'Change Theme',
              onTap: () => _showThemeSelector(context),
            ),

            _buildMenuTile(
              context,
              icon: Iconsax.logout,
              title: 'Logout',
              onTap: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),

            _buildMenuTile(
              context,
              icon: Iconsax.trash,
              title: 'Delete Account',
              textColor: AppColors.errorRed,
              onTap: () => _deleteAccount(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: textColor ?? themeProvider.primaryColor,
          size: 24.sp,
        ),
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: textColor ?? (isDark ? AppColors.darkText : AppColors.lightText),
          ),
        ),
        trailing: Icon(
          Iconsax.arrow_right_3,
          color: AppColors.greyText,
          size: 20.sp,
        ),
        tileColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}