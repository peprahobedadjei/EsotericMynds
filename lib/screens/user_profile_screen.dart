import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/user_profile_service.dart';
import '../utils/constants.dart';
import '../utils/string_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProfileScreen extends StatefulWidget {
  final int userId;
  final String username;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _userProfileService = UserProfileService();
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isFriend = false;
  bool _isAddingFriend = false;
  List<dynamic> _friends = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadFriends();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    
    final response = await _userProfileService.getUserProfile(widget.userId);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _userProfile = response.data;
        }
      });
    }
  }

  Future<void> _loadFriends() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.getAccessToken();
      
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/friends/'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final friendsList = jsonDecode(response.body) as List;
        setState(() {
          _friends = friendsList;
          _isFriend = friendsList.any((friend) => 
            friend['friend_profile']['user'] == widget.userId
          );
        });
      }
    } catch (e) {
      print('Load friends error: $e');
    }
  }

  Future<void> _addFriend() async {
    if (_isAddingFriend) return;
    
    setState(() => _isAddingFriend = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.getAccessToken();
      
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/friends/${widget.userId}/'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (mounted) {
        setState(() => _isAddingFriend = false);

        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() => _isFriend = true);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Friend added successfully!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add friend',        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAddingFriend = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}',        style: GoogleFonts.montserrat(
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
          '@${widget.username}',
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: themeProvider.primaryColor,
              ),
            )
          : _userProfile == null
              ? Center(
                  child: Text(
                    'Failed to load profile',
                    style: GoogleFonts.montserrat(
                      color: AppColors.greyText,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 60.r,
                        backgroundColor: themeProvider.primaryColor,
                        backgroundImage: _userProfile!.profilePictureUrl != null &&
                                _userProfile!.profilePictureUrl!.isNotEmpty
                            ? NetworkImage(_userProfile!.profilePictureUrl!)
                            : null,
                        child: _userProfile!.profilePictureUrl == null ||
                                _userProfile!.profilePictureUrl!.isEmpty
                            ? Text(
                                StringHelper.getFirstChar(_userProfile!.username),
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
                        _userProfile!.name,
                        style: GoogleFonts.montserrat(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // Username
                      Text(
                        '@${_userProfile!.username}',
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          color: AppColors.greyText,
                        ),
                      ),

                      if (_userProfile!.bio.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            _userProfile!.bio,
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

                      // Add Friend / You are friends button
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _isFriend ? null : _addFriend,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFriend 
                                ? themeProvider.primaryColor.withOpacity(0.2)
                                : themeProvider.primaryColor,
                            disabledBackgroundColor: themeProvider.primaryColor.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: _isAddingFriend
                              ? SizedBox(
                                  width: 24.w,
                                  height: 24.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isFriend ? Iconsax.tick_circle5 : Iconsax.user_add,
                                      color: _isFriend 
                                          ? themeProvider.primaryColor
                                          : Colors.white,
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      _isFriend ? 'You are friends' : 'Add Friend',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: _isFriend 
                                            ? themeProvider.primaryColor
                                            : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}