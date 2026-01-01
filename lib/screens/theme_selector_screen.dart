import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class ThemeSelectorScreen extends StatelessWidget {
  const ThemeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          'Change Theme',
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(24.w),
        children: [
          // Dark/Light Mode Toggle
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDark ? Iconsax.moon : Iconsax.sun_1,
                      color: themeProvider.primaryColor,
                      size: 24.sp,
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      'Dark Mode',
                      style: GoogleFonts.montserrat(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: isDark,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  activeColor: themeProvider.primaryColor,
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Theme Color Selector
          Text(
            'Choose Theme Color',
            style: GoogleFonts.montserrat(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),

          SizedBox(height: 16.h),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 20.h,
              childAspectRatio: 0.75, // Adjust height to width ratio
            ),
            itemCount: AppColors.themeColors.length,
            itemBuilder: (context, index) {
              final color = AppColors.themeColors[index];
              final colorName = AppColors.themeColorNames[index];
              final isSelected = themeProvider.themeColorIndex == index;

              return GestureDetector(
                onTap: () => themeProvider.setThemeColor(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              Iconsax.tick_circle5,
                              color: Colors.white,
                              size: 20.sp,
                            )
                          : null,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      colorName,
                      style: GoogleFonts.montserrat(
                        fontSize: 10.sp,
                        color: isSelected
                            ? (isDark ? AppColors.darkText : AppColors.lightText)
                            : AppColors.greyText,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}