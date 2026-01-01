import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: GoogleFonts.montserrat(
        fontSize: 14.sp,
        color: isDark ? AppColors.darkText : AppColors.lightText,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.montserrat(
          fontSize: 14.sp,
          color: AppColors.greyText,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: AppColors.greyText,
                size: 20.sp,
              )
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark
            ? const Color(0xFF1A1A1A)
            : const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppColors.primaryOrange,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppColors.errorRed,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppColors.errorRed,
            width: 1.5,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
      ),
    );
  }
}