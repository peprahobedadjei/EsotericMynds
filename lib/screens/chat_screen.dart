import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';
import '../utils/constants.dart';
import '../utils/string_helper.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final int userId;
  final String username;
  final String name;
  final String? profilePictureUrl;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.name,
    this.profilePictureUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    print('ChatScreen: Loading messages for user ${widget.userId} (${widget.username})');
    
    final response = await _chatService.getMessages(widget.userId);

    print('ChatScreen: Response success: ${response.success}');
    print('ChatScreen: Messages count: ${response.data?.length ?? 0}');

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _messages = response.data!;
          _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
          print('ChatScreen: After sorting, ${_messages.length} messages');
        }
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    final response = await _chatService.sendMessage(
      receiverId: widget.userId,
      content: content,
    );

    if (mounted) {
      setState(() => _isSending = false);

      if (response.success && response.data != null) {
        setState(() {
          _messages.add(response.data!);
        });

        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message',        style: GoogleFonts.montserrat(
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

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inDays == 0) {
        return DateFormat('HH:mm').format(dateTime);
      } else if (diff.inDays == 1) {
        return 'Yesterday ${DateFormat('HH:mm').format(dateTime)}';
      } else {
        return DateFormat('MMM dd, HH:mm').format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
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
        title: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: themeProvider.primaryColor,
              backgroundImage: widget.profilePictureUrl != null &&
                      widget.profilePictureUrl!.isNotEmpty
                  ? NetworkImage(widget.profilePictureUrl!)
                  : null,
              child: widget.profilePictureUrl == null ||
                      widget.profilePictureUrl!.isEmpty
                  ? Text(
                      StringHelper.getFirstChar(widget.username),
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  Text(
                    '@${widget.username}',
                    style: GoogleFonts.montserrat(
                      fontSize: 12.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: themeProvider.primaryColor,
                    ),
                  )
                : _messages.isEmpty
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
                              'No messages yet',
                              style: GoogleFonts.montserrat(
                                fontSize: 16.sp,
                                color: AppColors.greyText,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Start the conversation!',
                              style: GoogleFonts.montserrat(
                                fontSize: 14.sp,
                                color: AppColors.greyText,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16.w),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isSentByMe = message.sender.id == currentUserId;

                          return _buildMessageBubble(
                            message: message,
                            isSentByMe: isSentByMe,
                            isDark: isDark,
                            themeProvider: themeProvider,
                          );
                        },
                      ),
          ),

          // Message input
          Container(
            padding: EdgeInsets.all(16.w),
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: GoogleFonts.montserrat(
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.montserrat(
                        color: AppColors.greyText,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  decoration: BoxDecoration(
                    color: themeProvider.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: _isSending
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Icon(
                            Iconsax.send_1,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                    onPressed: _isSending ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required ChatMessage message,
    required bool isSentByMe,
    required bool isDark,
    required ThemeProvider themeProvider,
  }) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 10.h,
        ),
        constraints: BoxConstraints(
          maxWidth: 0.7.sw,
        ),
        decoration: BoxDecoration(
          color: isSentByMe
              ? themeProvider.primaryColor
              : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: isSentByMe ? Radius.circular(16.r) : Radius.circular(4.r),
            bottomRight: isSentByMe ? Radius.circular(4.r) : Radius.circular(16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: GoogleFonts.montserrat(
                fontSize: 14.sp,
                color: isSentByMe
                    ? Colors.white
                    : (isDark ? AppColors.darkText : AppColors.lightText),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              _formatTime(message.timestamp),
              style: GoogleFonts.montserrat(
                fontSize: 11.sp,
                color: isSentByMe
                    ? Colors.white.withOpacity(0.7)
                    : AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}