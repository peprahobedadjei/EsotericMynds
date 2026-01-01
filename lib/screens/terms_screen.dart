import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../utils/constants.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Terms of Use',
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DeepThinkers Terms of Use',
              style: GoogleFonts.montserrat(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Welcome to DeepThinkers, a platform designed to foster intelligent discourse and exchange of ideas. By using our app, you agree to comply with these Terms of Use. Please read them carefully.',
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            SizedBox(height: 20.h),
            _buildSection(
              context,
              'User Conduct',
              'DeepThinkers maintains a zero-tolerance policy for objectionable content and abusive behavior. You agree to use the app in a responsible manner and refrain from engaging in any activities that could be deemed harmful, offensive, or illegal.',
            ),
            _buildSection(
              context,
              'Objectionable Content',
              'Objectionable content includes, but is not limited to:\n\n• Hate speech, discriminatory remarks, or encouragement of violence against others\n• Explicit or graphic content, including nudity or extreme violence\n• Illegal activities or promotion of illegal goods/services\n• Spam, unwanted advertising, or phishing attempts\n• Copyrighted material or intellectual property infringement',
            ),
            _buildSection(
              context,
              'Abusive Behavior',
              'Abusive behavior includes, but is not limited to:\n\n• Harassment, threats, or intimidation of other users\n• Impersonation of others or providing false information\n• Disruption of the app\'s services or interference with other users\' experiences\n• Unauthorized access or attempts to compromise the app\'s security',
            ),
            _buildSection(
              context,
              'Consequences',
              'Any violation of these Terms of Use will result in immediate consequences, which may include:\n\n• Removal of objectionable content\n• Suspension or termination of your account\n• Reporting of illegal activities to relevant authorities',
            ),
            _buildSection(
              context,
              'User Agreement',
              'By using DeepThinkers, you agree to these Terms of Use. We reserve the right to update these Terms of Use at any time. Continued use of DeepThinkers after any changes constitutes acceptance of the updated terms.',
            ),
            _buildSection(
              context,
              'Contact Us',
              'If you have any questions or concerns, please contact our support team at support@deepthinkers.com',
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          content,
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            color: isDark ? AppColors.darkText : AppColors.lightText,
            height: 1.5,
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}