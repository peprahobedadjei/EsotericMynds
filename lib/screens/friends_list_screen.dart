import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/string_helper.dart';
import 'user_profile_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  List<dynamic> _friends = [];
  List<dynamic> _filteredFriends = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.getAccessToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/friends/'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      print('Friends list status: ${response.statusCode}');
      print('Friends list response: ${response.body}');

      if (response.statusCode == 200) {
        final friendsList = jsonDecode(response.body) as List;
        setState(() {
          _friends = friendsList;
          _filteredFriends = friendsList;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Load friends error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterFriends(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredFriends = _friends;
      } else {
        _filteredFriends = _friends.where((friend) {
          final profile = friend['friend_profile'];
          final username = profile['username'].toString().toLowerCase();
          final name = profile['name'].toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return username.contains(searchLower) || name.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Friends',
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              style: GoogleFonts.montserrat(
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              decoration: InputDecoration(
                hintText: 'Search friends...',
                hintStyle: GoogleFonts.montserrat(
                  color: AppColors.greyText,
                ),
                prefixIcon: Icon(
                  Iconsax.search_normal,
                  color: AppColors.greyText,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterFriends,
            ),
          ),

          // Friends list
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: themeProvider.primaryColor,
                    ),
                  )
                : _filteredFriends.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.user,
                              size: 64.sp,
                              color: AppColors.greyText,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No friends yet'
                                  : 'No friends found',
                              style: GoogleFonts.montserrat(
                                fontSize: 16.sp,
                                color: AppColors.greyText,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadFriends,
                        color: themeProvider.primaryColor,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: _filteredFriends.length,
                          itemBuilder: (context, index) {
                            final friend = _filteredFriends[index];
                            final profile = friend['friend_profile'];
                            
                            return _buildFriendTile(
                              context,
                              userId: profile['user'],
                              username: profile['username'],
                              name: profile['name'],
                              profilePictureUrl: profile['profile_picture_url'],
                              isDark: isDark,
                              themeProvider: themeProvider,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendTile(
    BuildContext context, {
    required int userId,
    required String username,
    required String name,
    required String? profilePictureUrl,
    required bool isDark,
    required ThemeProvider themeProvider,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserProfileScreen(
                userId: userId,
                username: username,
              ),
            ),
          );
        },
        leading: CircleAvatar(
          radius: 24.r,
          backgroundColor: themeProvider.primaryColor,
          backgroundImage: profilePictureUrl != null && profilePictureUrl.isNotEmpty
              ? NetworkImage(profilePictureUrl)
              : null,
          child: profilePictureUrl == null || profilePictureUrl.isEmpty
              ? Text(
                  StringHelper.getFirstChar(username),
                  style: GoogleFonts.montserrat(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        title: Text(
          name,
          style: GoogleFonts.montserrat(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        subtitle: Text(
          '@$username',
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            color: AppColors.greyText,
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