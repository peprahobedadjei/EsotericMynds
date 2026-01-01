import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/theme_provider.dart';
import '../services/user_profile_service.dart';
import '../utils/constants.dart';
import '../utils/string_helper.dart';
import '../utils/time_helper.dart';
import '../screens/user_profile_screen.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _showFullContent = false;
  bool _isReacting = false;
  String? _userProfilePictureUrl;
  bool _loadingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfilePicture();
  }

  Future<void> _loadUserProfilePicture() async {
    // Check if this post is by the logged-in user
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.id ?? 0;

    if (widget.post.user.id == currentUserId) {
      // Use logged-in user's profile picture
      setState(() {
        _userProfilePictureUrl = authProvider.currentUser?.profilePictureUrl;
      });
      return;
    }

    // For other users, fetch their profile
    if (_loadingProfile) return;
    setState(() => _loadingProfile = true);

    final userProfileService = UserProfileService();
    final response = await userProfileService.getUserProfile(widget.post.user.id);

    if (mounted && response.success && response.data != null) {
      setState(() {
        _userProfilePictureUrl = response.data!.profilePictureUrl;
        _loadingProfile = false;
      });
    } else if (mounted) {
      setState(() => _loadingProfile = false);
    }
  }

  void _viewUserProfile() {
    // Check if this is the logged-in user
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.id ?? 0;

    if (widget.post.user.id == currentUserId) {
      // Don't navigate if it's the logged-in user's post
      return;
    }

    // Navigate to user profile screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          userId: widget.post.user.id,
          username: widget.post.user.username,
        ),
      ),
    );
  }

  void _handleReaction(String reactionType) async {
    if (_isReacting) return; // Prevent multiple taps
    
    setState(() => _isReacting = true);
    
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    
    // If user already reacted with the same type, remove reaction
    if (widget.post.userReaction == reactionType) {
      await postProvider.removeReaction(widget.post.id);
    } else {
      // Otherwise, add/change reaction
      await postProvider.reactToPost(widget.post.id, reactionType);
    }
    
    if (mounted) {
      setState(() => _isReacting = false);
    }
  }

  void _handleFlag() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          title: Text(
            'Flag Post',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          content: Text(
            'Are you sure you want to flag this post as inappropriate?',
            style: GoogleFonts.montserrat(
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(color: AppColors.greyText),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Flag',
                style: GoogleFonts.montserrat(
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      await postProvider.flagPost(widget.post.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post flagged successfully',        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    }
  }

  void _searchByUser() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.setSearchQuery(widget.post.user.username);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentUserId = authProvider.currentUser?.id ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Row(
            children: [
              // Profile Picture
              GestureDetector(
                onTap: _viewUserProfile,
                child: CircleAvatar(
                  radius: 20.r,
                  backgroundColor: themeProvider.primaryColor,
                  backgroundImage: _userProfilePictureUrl != null &&
                          _userProfilePictureUrl!.isNotEmpty
                      ? NetworkImage(_userProfilePictureUrl!)
                      : null,
                  child: _userProfilePictureUrl == null ||
                          _userProfilePictureUrl!.isEmpty
                      ? Text(
                          StringHelper.getFirstChar(widget.post.user.username),
                          style: GoogleFonts.montserrat(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
              SizedBox(width: 12.w),
              
              // Username and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _viewUserProfile,
                      child: Text(
                        widget.post.user.username,
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                    ),
                    Text(
                      TimeAgoHelper.getTimeAgo(widget.post.createdAt),
                      style: GoogleFonts.montserrat(
                        fontSize: 12.sp,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Room badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  widget.post.room.name,
                  style: GoogleFonts.montserrat(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.primaryColor,
                  ),
                ),
              ),
              
              // Flag button (only if not user's own post)
              if (widget.post.user.id != currentUserId) ...[
                SizedBox(width: 8.w),
                IconButton(
                  icon: Icon(
                    Iconsax.flag,
                    size: 20.sp,
                    color: AppColors.greyText,
                  ),
                  onPressed: _handleFlag,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // Post Content
          _buildContent(isDark),
          
          // Media if available
          if (widget.post.mediaUrl != null && widget.post.mediaUrl!.isNotEmpty)
            Column(
              children: [
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    widget.post.mediaUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200.h,
                        color: isDark
                            ? const Color(0xFF2A2A2A)
                            : Colors.grey[200],
                        child: const Center(
                          child: Icon(Iconsax.gallery, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          
          SizedBox(height: 16.h),
          
          // Reaction Buttons
          Row(
            children: [
              // Deep Reaction
              _buildReactionButton(
                icon: Iconsax.like_15,
                count: widget.post.deepCount,
                isActive: widget.post.userReaction == 'Deep',
                onTap: () => _handleReaction('Deep'),
                isDark: isDark,
              ),
              
              SizedBox(width: 20.w),
              
              // Shallow Reaction
              _buildReactionButton(
                icon: Iconsax.dislike,
                count: widget.post.shallowCount,
                isActive: widget.post.userReaction == 'Shallow',
                onTap: () => _handleReaction('Shallow'),
                isDark: isDark,
              ),
              
              // Loading indicator when reacting
              if (_isReacting) ...[
                SizedBox(width: 16.w),
                SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(themeProvider.primaryColor),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final content = widget.post.content;
    final shouldTruncate = content.length > 200;

    if (!shouldTruncate || _showFullContent) {
      return Text(
        content,
        style: GoogleFonts.montserrat(
          fontSize: 14.sp,
          color: isDark ? AppColors.darkText : AppColors.lightText,
          height: 1.5,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${content.substring(0, 200)}...',
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            color: isDark ? AppColors.darkText : AppColors.lightText,
            height: 1.5,
          ),
        ),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: () {
            setState(() {
              _showFullContent = true;
            });
          },
          child: Text(
            'Read more',
            style: GoogleFonts.montserrat(
              fontSize: 13.sp,
              color: themeProvider.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReactionButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return GestureDetector(
      onTap: _isReacting ? null : onTap,
      child: Opacity(
        opacity: _isReacting ? 0.5 : 1.0,
        child: Row(
          children: [
            Icon(
              icon,
              size: 22.sp,
              color: isActive
                  ? themeProvider.primaryColor
                  : (isDark ? AppColors.greyText : Colors.grey[600]),
            ),
            SizedBox(width: 6.w),
            Text(
              count.toString(),
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? themeProvider.primaryColor
                    : (isDark ? AppColors.darkText : AppColors.lightText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}