import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/post_provider.dart';
import '../services/profile_service.dart';
import '../models/room.dart';
import '../utils/constants.dart';

class ChatRoomsScreen extends StatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  State<ChatRoomsScreen> createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  final _profileService = ProfileService();
  Map<int, bool> _joiningRooms = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchRooms();
    });
  }

  Future<void> _joinRoom(int roomId) async {
    setState(() => _joiningRooms[roomId] = true);

    final response = await _profileService.joinRoom(roomId);

    setState(() => _joiningRooms[roomId] = false);

    if (mounted) {
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Joined room successfully!',        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),),
            backgroundColor: AppColors.successGreen,
          ),
        );
        // Refresh rooms list
        Provider.of<PostProvider>(context, listen: false).fetchRooms();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message,        style: GoogleFonts.montserrat(
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

  bool _isUserMember(Room room, int userId) {
    return room.members.any((member) => member.id == userId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final postProvider = Provider.of<PostProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentUserId = authProvider.currentUser?.id ?? 0;

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
          'Chat Rooms',
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ),
      body: postProvider.rooms.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: themeProvider.primaryColor,
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: postProvider.rooms.length,
              itemBuilder: (context, index) {
                final room = postProvider.rooms[index];
                final isMember = _isUserMember(room, currentUserId);
                final isJoining = _joiningRooms[room.id] ?? false;

                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: isMember
                        ? Border.all(color: themeProvider.primaryColor, width: 2)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: themeProvider.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Iconsax.messages,
                          color: themeProvider.primaryColor,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.name,
                              style: GoogleFonts.montserrat(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkText : AppColors.lightText,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${room.members.length} members',
                              style: GoogleFonts.montserrat(
                                fontSize: 12.sp,
                                color: AppColors.greyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isMember)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: themeProvider.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'Member',
                            style: GoogleFonts.montserrat(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: themeProvider.primaryColor,
                            ),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: isJoining ? null : () => _joinRoom(room.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeProvider.primaryColor,
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: isJoining
                              ? SizedBox(
                                  width: 16.w,
                                  height: 16.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Join',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}