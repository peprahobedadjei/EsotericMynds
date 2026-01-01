import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/chat.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class ChatService {
  final _storage = StorageService();

  // Send message
  Future<ApiResponse<ChatMessage>> sendMessage({
    required int receiverId,
    required String content,
  }) async {
    try {
      final accessToken = _storage.getAccessToken();
      if (accessToken == null) {
        return ApiResponse.error('No access token');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/chat/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'receiver': receiverId,
          'content': content,
        }),
      );

      print('Send message status: ${response.statusCode}');
      print('Send message response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final message = ChatMessage.fromJson(data);
        return ApiResponse.success(message, 'Message sent');
      } else {
        return ApiResponse.error('Failed to send message');
      }
    } catch (e) {
      print('Send message error: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Get messages with a specific user
  Future<ApiResponse<List<ChatMessage>>> getMessages(int userId) async {
    try {
      final accessToken = _storage.getAccessToken();
      if (accessToken == null) {
        return ApiResponse.error('No access token');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/chat/?user_id=$userId'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      print('Get messages status: ${response.statusCode}');
      print('Get messages response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        // Parse all messages
        final allMessages = data.map((json) => ChatMessage.fromJson(json)).toList();
        
        // Get current user ID from storage
        final currentUserId = _storage.getUserData()?['user'] ?? 0;
        
        print('Current user ID: $currentUserId');
        print('Filtering messages for user: $userId');
        print('Total messages from API: ${allMessages.length}');
        
        // Filter messages to only include conversations between current user and target user
        final filteredMessages = allMessages.where((message) {
          // Message from me to them
          final sentByMeToThem = message.sender.id == currentUserId && message.receiver == userId;
          // Message from them to me
          final sentByThemToMe = message.sender.id == userId && message.receiver == currentUserId;
          
          return sentByMeToThem || sentByThemToMe;
        }).toList();
        
        print('Filtered messages count: ${filteredMessages.length}');
        for (var msg in filteredMessages) {
          print('Message: sender=${msg.sender.id}, receiver=${msg.receiver}, content=${msg.content}');
        }
        
        return ApiResponse.success(filteredMessages, 'Messages loaded');
      } else {
        return ApiResponse.error('Failed to load messages');
      }
    } catch (e) {
      print('Get messages error: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Get all chat conversations (list of friends with last message)
  Future<ApiResponse<List<Map<String, dynamic>>>> getChatList() async {
    try {
      final accessToken = _storage.getAccessToken();
      if (accessToken == null) {
        return ApiResponse.error('No access token');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/chat/'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      print('Get chat list status: ${response.statusCode}');
      print('Get chat list response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        // Group messages by conversation partner
        Map<int, List<ChatMessage>> conversationsMap = {};
        
        for (var json in data) {
          final message = ChatMessage.fromJson(json);
          final partnerId = message.sender.id;
          
          if (!conversationsMap.containsKey(partnerId)) {
            conversationsMap[partnerId] = [];
          }
          conversationsMap[partnerId]!.add(message);
        }

        // Convert to list format
        List<Map<String, dynamic>> conversations = conversationsMap.entries.map((entry) {
          final messages = entry.value;
          messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          
          return {
            'partnerId': entry.key,
            'partnerUsername': messages.first.sender.username,
            'lastMessage': messages.first.content,
            'lastMessageTime': messages.first.timestamp,
            'messages': messages,
          };
        }).toList();

        // Sort by last message time
        conversations.sort((a, b) => 
          b['lastMessageTime'].compareTo(a['lastMessageTime'])
        );

        return ApiResponse.success(conversations, 'Chat list loaded');
      } else {
        return ApiResponse.error('Failed to load chat list');
      }
    } catch (e) {
      print('Get chat list error: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
}