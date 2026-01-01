import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.errorMessage ?? 'Login failed',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
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

                // Theme Toggle
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      ).toggleTheme();
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
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                // Logo
                Center(
                  child: Image.asset(
                    isDark
                        ? 'assets/images/logo_dark.png'
                        : 'assets/images/logo_light.png',
                    width: 120.w,
                    height: 120.w,
                  ),
                ),

                SizedBox(height: 40.h),

                // Title
                Text(
                  'Welcome Back',
                  style: GoogleFonts.montserrat(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'Login to continue',
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    color: AppColors.greyText,
                  ),
                ),

                SizedBox(height: 40.h),

                // Username Field
                CustomTextField(
                  controller: _usernameController,
                  hintText: 'Username',
                  prefixIcon: Iconsax.user,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
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
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 40.h),

                // Login Button
                CustomButton(
                  text: 'Login',
                  onPressed: authProvider.isLoading ? null : _handleLogin,
                  isLoading: authProvider.isLoading,
                ),

                SizedBox(height: 24.h),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        color: AppColors.greyText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Register',
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
