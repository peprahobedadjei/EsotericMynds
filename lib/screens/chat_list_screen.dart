import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/string_helper.dart';
import 'chat_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<dynamic> _friends = [];
  bool _isLoading = true;

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

      if (response.statusCode == 200) {
        final friendsList = jsonDecode(response.body) as List;
        setState(() {
          _friends = friendsList;
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

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
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
          : _friends.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.message,
                        size: 64.sp,
                        color: AppColors.greyText,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No friends to chat with yet',
                        style: GoogleFonts.montserrat(
                          fontSize: 16.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Add friends to start chatting!',
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
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
                    padding: EdgeInsets.all(16.w),
                    itemCount: _friends.length,
                    itemBuilder: (context, index) {
                      final friend = _friends[index];
                      final profile = friend['friend_profile'];

                      return _buildChatTile(
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
    );
  }

  Widget _buildChatTile(
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
              builder: (_) => ChatScreen(
                userId: userId,
                username: username,
                name: name,
                profilePictureUrl: profilePictureUrl,
              ),
            ),
          ).then((_) => _loadFriends()); // Refresh on return
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
          'Tap to chat',
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            color: AppColors.greyText,
          ),
        ),
        trailing: Icon(
          Iconsax.message,
          color: themeProvider.primaryColor,
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