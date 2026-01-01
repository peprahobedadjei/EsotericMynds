import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/post_provider.dart';
import '../utils/constants.dart';
import '../utils/string_helper.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';
import 'profile_detail_screen.dart';
import 'friends_list_screen.dart';
import 'chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const FriendsListScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          selectedItemColor: themeProvider.primaryColor,
          unselectedItemColor: AppColors.greyText,
          selectedLabelStyle: GoogleFonts.montserrat(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.montserrat(
            fontSize: 12.sp,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Iconsax.home),
              activeIcon: Icon(Iconsax.home_15),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.user),
              activeIcon: Icon(Iconsax.profile_2user),
              label: 'Friends',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.message),
              activeIcon: Icon(Iconsax.message_text_15),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.user_square),
              activeIcon: Icon(Iconsax.profile_circle5),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Feed Screen
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Fetch posts and rooms when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      postProvider.fetchPosts();
      postProvider.fetchRooms();
    });
  }

  void _showRoomSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.id ?? 0;

    // Filter rooms where user is a member
    final userRooms = postProvider.rooms.where((room) {
      return room.members.any((member) => member.id == currentUserId);
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
              
              // All Posts option
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: postProvider.selectedRoom == null
                        ? themeProvider.primaryColor.withOpacity(0.2)
                        : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Iconsax.global,
                    color: postProvider.selectedRoom == null
                        ? themeProvider.primaryColor
                        : AppColors.greyText,
                  ),
                ),
                title: Text(
                  'All Posts',
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: postProvider.selectedRoom == null
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                onTap: () {
                  postProvider.selectRoom(null);
                  Navigator.pop(context);
                },
              ),
              
              // Room list
              ...userRooms.map((room) {
                final isSelected = postProvider.selectedRoom?.id == room.id;
                return ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? themeProvider.primaryColor.withOpacity(0.2)
                          : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Iconsax.menu_board,
                      color: isSelected
                          ? themeProvider.primaryColor
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
                    postProvider.selectRoom(room);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final postProvider = Provider.of<PostProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                style: GoogleFonts.montserrat(
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by username...',
                  hintStyle: GoogleFonts.montserrat(
                    color: AppColors.greyText,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  postProvider.setSearchQuery(value);
                },
              )
            : Row(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Deep',
                          style: GoogleFonts.montserrat(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                        TextSpan(
                          text: 'Thinkers',
                          style: GoogleFonts.montserrat(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        actions: [
          if (!_isSearching) ...[
            // Search button
            IconButton(
              icon: Icon(
                Iconsax.search_normal,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
            
            // Room selector button
            IconButton(
              icon: Icon(
                Iconsax.menu_board,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              onPressed: _showRoomSelector,
            ),
            
            // Theme toggle
            IconButton(
              icon: Icon(
                isDark ? Iconsax.sun_1 : Iconsax.moon,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
          ] else ...[
            // Close search button
            IconButton(
              icon: Icon(
                Iconsax.close_circle,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                });
                postProvider.clearSearch();
              },
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await postProvider.fetchPosts();
        },
        color: themeProvider.primaryColor,
        child: postProvider.isLoading && postProvider.allPosts.isEmpty
            ? Center(
                child: CircularProgressIndicator(
                  color: themeProvider.primaryColor,
                ),
              )
            : Column(
                children: [
                  // Create post button (only show when not searching)
                  if (!_isSearching)
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreatePostScreen(),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.all(16.w),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A1A1A)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundColor: themeProvider.primaryColor,
                              backgroundImage: authProvider.currentUser?.profilePictureUrl != null &&
                                      authProvider.currentUser!.profilePictureUrl!.isNotEmpty
                                  ? NetworkImage(authProvider.currentUser!.profilePictureUrl!)
                                  : null,
                              child: authProvider.currentUser?.profilePictureUrl == null ||
                                      authProvider.currentUser!.profilePictureUrl!.isEmpty
                                  ? Text(
                                      StringHelper.getFirstChar(authProvider.currentUser?.username),
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                "What's on your mind?",
                                style: GoogleFonts.montserrat(
                                  fontSize: 14.sp,
                                  color: AppColors.greyText,
                                ),
                              ),
                            ),
                            Icon(
                              Iconsax.gallery,
                              color: themeProvider.primaryColor,
                              size: 24.sp,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Search results indicator
                  if (_isSearching && postProvider.searchQuery != null && postProvider.searchQuery!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      color: themeProvider.primaryColor.withOpacity(0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Searching: ${postProvider.searchQuery}',
                            style: GoogleFonts.montserrat(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: themeProvider.primaryColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSearching = false;
                              });
                              postProvider.clearSearch();
                            },
                            child: Text(
                              'Clear',
                              style: GoogleFonts.montserrat(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: themeProvider.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Selected room indicator
                  if (postProvider.selectedRoom != null && !_isSearching)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      color: themeProvider.primaryColor.withOpacity(0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Viewing: ${postProvider.selectedRoom!.name}',
                            style: GoogleFonts.montserrat(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: themeProvider.primaryColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => postProvider.selectRoom(null),
                            child: Text(
                              'View All',
                              style: GoogleFonts.montserrat(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: themeProvider.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Posts list
                  Expanded(
                    child: postProvider.filteredPosts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.document,
                                  size: 64.sp,
                                  color: AppColors.greyText,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  _isSearching
                                      ? 'No posts found'
                                      : 'No posts yet',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16.sp,
                                    color: AppColors.greyText,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16.w),
                            itemCount: postProvider.filteredPosts.length,
                            itemBuilder: (context, index) {
                              return PostCard(
                                post: postProvider.filteredPosts[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Placeholder screens
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Import the detailed profile screen
    return const ProfileDetailScreen();
  }
}