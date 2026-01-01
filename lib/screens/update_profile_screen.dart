import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/string_helper.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  File? _newProfilePicture;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: authProvider.currentUser?.name ?? '');
    _usernameController = TextEditingController(text: authProvider.currentUser?.username ?? '');
    _emailController = TextEditingController(text: authProvider.currentUser?.email ?? '');
    _bioController = TextEditingController(text: authProvider.currentUser?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final themeProvider = Provider.of<ThemeProvider>(context);
          return Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Update Profile Picture',
                  style: GoogleFonts.montserrat(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: Icon(Iconsax.camera, color: themeProvider.primaryColor),
                  title: Text(
                    'Take Photo',
                    style: GoogleFonts.montserrat(
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(Iconsax.gallery, color: themeProvider.primaryColor),
                  title: Text(
                    'Choose from Gallery',
                    style: GoogleFonts.montserrat(
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source != null && mounted) {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 500,
          maxHeight: 500,
        );

        if (pickedFile != null && mounted) {
          setState(() {
            _newProfilePicture = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e',        style: GoogleFonts.montserrat(
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

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.updateProfile(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        bio: _bioController.text.trim(),
        profilePicture: _newProfilePicture,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully!',        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),),
              backgroundColor: AppColors.successGreen,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Update failed',        style: GoogleFonts.montserrat(
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
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Update Profile',
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60.r,
                      backgroundColor: themeProvider.primaryColor,
                      backgroundImage: _newProfilePicture != null
                          ? FileImage(_newProfilePicture!)
                          : (authProvider.currentUser?.profilePictureUrl != null &&
                                  authProvider.currentUser!.profilePictureUrl!.isNotEmpty
                              ? NetworkImage(authProvider.currentUser!.profilePictureUrl!)
                              : null) as ImageProvider?,
                      child: _newProfilePicture == null &&
                              (authProvider.currentUser?.profilePictureUrl == null ||
                                  authProvider.currentUser!.profilePictureUrl!.isEmpty)
                          ? Text(
                              StringHelper.getFirstChar(authProvider.currentUser?.username),
                              style: GoogleFonts.montserrat(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: themeProvider.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.camera,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // Name Field
              CustomTextField(
                controller: _nameController,
                hintText: 'Full Name',
                prefixIcon: Iconsax.user,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 20.h),
              
              // Username Field
              CustomTextField(
                controller: _usernameController,
                hintText: 'Username',
                prefixIcon: Iconsax.user_tag,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 20.h),
              
              // Email Field
              CustomTextField(
                controller: _emailController,
                hintText: 'Email',
                prefixIcon: Iconsax.sms,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 20.h),
              
              // Bio Field
              CustomTextField(
                controller: _bioController,
                hintText: 'Bio',
                prefixIcon: Iconsax.document_text,
                maxLines: 4,
              ),
              
              SizedBox(height: 32.h),
              
              // Update Button
              CustomButton(
                text: 'Update Profile',
                onPressed: authProvider.isLoading ? null : _updateProfile,
                isLoading: authProvider.isLoading,
                backgroundColor: themeProvider.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}