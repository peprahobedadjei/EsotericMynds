import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.isLoggedIn) {
        // Load user data
        await authProvider.loadUser();
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              isDark
                  ? 'assets/images/logo_dark.png'
                  : 'assets/images/logo_light.png',
              width: 150.w,
              height: 150.w,
            ),
            
            SizedBox(height: 20.h),
            
            // App Name
            Text(
              'Welcome to DeepThinkers',
              style: GoogleFonts.montserrat(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: 8.h),
            
            // Tagline
            Text(
              'Express your Esoteric Thoughts.',
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
            ),
            
            SizedBox(height: 40.h),
            
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
            ),
            
            SizedBox(height: 16.h),
            
            Text(
              'Authenticating ...',
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}