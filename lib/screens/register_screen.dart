import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';
import 'terms_screen.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  File? _profileImage;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  'Choose Profile Picture',
                  style: GoogleFonts.montserrat(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: const Icon(Iconsax.camera, color: AppColors.primaryOrange),
                  title: Text(
                    'Take Photo',
                    style: GoogleFonts.montserrat(
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Iconsax.gallery, color: AppColors.primaryOrange),
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
            _profileImage = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e',         style: GoogleFonts.montserrat(
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

  Future<void> _handleRegister() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please agree to the Terms of Use',         style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        profilePicture: _profileImage,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration successful!',        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),),
              backgroundColor: AppColors.successGreen,
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Registration failed',        style: GoogleFonts.montserrat(
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
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                
                // Back Button and Theme Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Iconsax.arrow_left,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    GestureDetector(
                      onTap: () {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .toggleTheme();
                      },
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A1A1A)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          isDark ? Iconsax.sun_1 : Iconsax.moon,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 20.h),
                
                // Title
                Text(
                  'Create Account',
                  style: GoogleFonts.montserrat(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                Text(
                  'Join the DeepThinkers community',
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    color: AppColors.greyText,
                  ),
                ),
                
                SizedBox(height: 30.h),
                
                // Profile Picture
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFFF5F5F5),
                        border: Border.all(
                          color: AppColors.primaryOrange,
                          width: 2,
                        ),
                      ),
                      child: _profileImage != null
                          ? ClipOval(
                              child: Image.file(
                                _profileImage!,
                                fit: BoxFit.cover,
                                width: 120.w,
                                height: 120.w,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.camera,
                                  size: 32.sp,
                                  color: AppColors.primaryOrange,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Add Photo',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12.sp,
                                    color: AppColors.greyText,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                
                SizedBox(height: 30.h),
                
                // Name Field
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Full Name',
                  prefixIcon: Iconsax.user,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
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
                      return 'Please enter a username';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
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
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 20.h),
                
                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  prefixIcon: Iconsax.lock,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                      color: AppColors.greyText,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 20.h),
                
                // Confirm Password Field
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  prefixIcon: Iconsax.lock_1,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Iconsax.eye_slash : Iconsax.eye,
                      color: AppColors.greyText,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 24.h),
                
                // Terms Checkbox
                Row(
                  children: [
                    SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        activeColor: AppColors.primaryOrange,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TermsScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.montserrat(
                              fontSize: 13.sp,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms of Use',
                                style: GoogleFonts.montserrat(
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 32.h),
                
                // Register Button
                CustomButton(
                  text: 'Create Account',
                  onPressed: authProvider.isLoading ? null : _handleRegister,
                  isLoading: authProvider.isLoading,
                ),
                
                SizedBox(height: 24.h),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        color: AppColors.greyText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Login',
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}