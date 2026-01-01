import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../models/room.dart';
import '../utils/constants.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  File? _selectedImage;
  Room? _selectedRoom;

  @override
  void initState() {
    super.initState();
    // Set default room if one is already selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      if (postProvider.selectedRoom != null) {
        setState(() {
          _selectedRoom = postProvider.selectedRoom;
        });
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
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
                  'Add Image',
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
        );

        if (pickedFile != null && mounted) {
          setState(() {
            _selectedImage = File(pickedFile.path);
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

  void _selectRoom() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.id ?? 0;

    // Filter rooms where user is a member
    final userRooms = postProvider.rooms.where((room) {
      return room.members.any((member) => member.id == currentUserId);
    }).toList();

    showModalBottomSheet(
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
                'Select Room',
                style: GoogleFonts.montserrat(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              SizedBox(height: 16.h),
              ...userRooms.map((room) {
                final isSelected = _selectedRoom?.id == room.id;
                return ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryOrange.withOpacity(0.2)
                          : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Iconsax.menu_board,
                      color: isSelected
                          ? AppColors.primaryOrange
                          : AppColors.greyText,
                    ),
                  ),
                  title: Text(
                    room.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedRoom = room;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text('Please enter some content',        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a room',        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    
    print('Creating post with room ID: ${_selectedRoom!.id}');
    print('Content: ${_contentController.text.trim()}');
    print('Has image: ${_selectedImage != null}');
    
    final success = await postProvider.createPost(
      content: _contentController.text.trim(),
      roomId: _selectedRoom!.id,
      media: _selectedImage,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('Post created successfully!',        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),),
            backgroundColor: AppColors.successGreen,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      } else {
        final errorMsg = postProvider.errorMessage ?? 'Failed to create post';
        print('Create post failed: $errorMsg');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg,        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Iconsax.close_circle,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Post',
          style: GoogleFonts.montserrat(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: postProvider.isCreatingPost ? null : _createPost,
            child: postProvider.isCreatingPost
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.primaryOrange),
                    ),
                  )
                : Text(
                    'Post',
                    style: GoogleFonts.montserrat(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryOrange,
                    ),
                  ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.primaryOrange,
                  backgroundImage: authProvider.currentUser?.profilePictureUrl != null &&
                          authProvider.currentUser!.profilePictureUrl!.isNotEmpty
                      ? NetworkImage(authProvider.currentUser!.profilePictureUrl!)
                      : null,
                  child: authProvider.currentUser?.profilePictureUrl == null ||
                          authProvider.currentUser!.profilePictureUrl!.isEmpty
                      ? Text(
                          (authProvider.currentUser?.username ?? 'U')[0].toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authProvider.currentUser?.username ?? 'User',
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    GestureDetector(
                      onTap: _selectRoom,
                      child: Row(
                        children: [
                          Text(
                            _selectedRoom != null
                                ? _selectedRoom!.name
                                : 'Select Room',
                            style: GoogleFonts.montserrat(
                              fontSize: 12.sp,
                              color: _selectedRoom != null
                                  ? AppColors.primaryOrange
                                  : AppColors.greyText,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Iconsax.arrow_down_1,
                            size: 14.sp,
                            color: _selectedRoom != null
                                ? AppColors.primaryOrange
                                : AppColors.greyText,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 20.h),
            
            // Content text field
            TextField(
              controller: _contentController,
              maxLines: null,
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: GoogleFonts.montserrat(
                  fontSize: 16.sp,
                  color: AppColors.greyText,
                ),
                border: InputBorder.none,
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // Selected image
            if (_selectedImage != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.close_circle,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            
            SizedBox(height: 20.h),
            
            // Insert image button
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A1A1A)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.gallery_add,
                      color: AppColors.primaryOrange,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Insert Image',
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryOrange,
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