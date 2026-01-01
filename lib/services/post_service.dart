import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/post.dart';
import '../models/room.dart';
import '../utils/constants.dart';
import 'http_service.dart';
import 'storage_service.dart';

class PostService {
  final _httpService = HttpService();
  final _storage = StorageService();

  // Get all posts
  Future<ApiResponse<List<Post>>> getAllPosts() async {
    try {
      final response = await _httpService.authenticatedRequest(
        method: 'GET',
        endpoint: ApiConstants.postsEndpoint,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final posts = data.map((json) => Post.fromJson(json)).toList();
        
        return ApiResponse.success(posts, 'Posts fetched successfully');
      } else {
        return ApiResponse.error('Failed to fetch posts');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Get all rooms
  Future<ApiResponse<List<Room>>> getAllRooms() async {
    try {
      final response = await _httpService.authenticatedRequest(
        method: 'GET',
        endpoint: ApiConstants.roomsEndpoint,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final rooms = data.map((json) => Room.fromJson(json)).toList();
        
        return ApiResponse.success(rooms, 'Rooms fetched successfully');
      } else {
        return ApiResponse.error('Failed to fetch rooms');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Create post with token refresh support
  Future<ApiResponse<Post>> createPost({
    required String content,
    required int roomId,
    File? media,
  }) async {
    try {
      // Try creating post
      var response = await _attemptCreatePost(content, roomId, media);
      
      // If token expired, refresh and retry
      if (response.statusCode == 401 || response.statusCode == 403) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'token_not_valid') {
          print('Token expired, attempting refresh...');
          
          // Refresh token
          final refreshed = await _refreshToken();
          
          if (refreshed) {
            print('Token refreshed, retrying create post...');
            // Retry with new token
            response = await _attemptCreatePost(content, roomId, media);
          } else {
            return ApiResponse.error('Session expired. Please login again.');
          }
        }
      }

      print('Create post status: ${response.statusCode}');
      print('Create post response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final post = Post.fromJson(data);
        
        return ApiResponse.success(post, 'Post created successfully');
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Failed to create post';
        
        if (errorData is Map) {
          if (errorData.containsKey('detail')) {
            errorMessage = errorData['detail'];
          } else {
            // Extract specific error messages
            errorMessage = errorData.entries
                .map((e) => '${e.key}: ${e.value}')
                .join(', ');
          }
        }
        
        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      print('Create post error: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Helper method to attempt creating post
  Future<http.Response> _attemptCreatePost(
    String content,
    int roomId,
    File? media,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.postsEndpoint}'),
    );

    // Get access token
    final accessToken = _storage.getAccessToken();
    if (accessToken == null) {
      throw Exception('No access token found');
    }

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $accessToken';

    // Add form fields
    request.fields['content'] = content;
    request.fields['room'] = roomId.toString();

    // Add media if available
    if (media != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'media',
          media.path,
        ),
      );
    }

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  // Helper method to refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _storage.getRefreshToken();
      
      if (refreshToken == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refreshTokenEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'];
        final currentRefreshToken = _storage.getRefreshToken()!;
        
        await _storage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: currentRefreshToken,
        );
        
        return true;
      } else {
        // Refresh token expired, clear all data
        await _storage.clearAll();
        return false;
      }
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  // React to post (Deep or Shallow)
  Future<ApiResponse<void>> reactToPost(int postId, String reactionType) async {
    try {
      final response = await _httpService.authenticatedRequest(
        method: 'POST',
        endpoint: ApiConstants.postReactEndpoint(postId),
        headers: {'Content-Type': 'application/json'},
        body: {'reaction_type': reactionType},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(null, 'Reaction added successfully');
      } else {
        return ApiResponse.error('Failed to react to post');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Remove reaction from post
  Future<ApiResponse<void>> removeReaction(int postId) async {
    try {
      final response = await _httpService.authenticatedRequest(
        method: 'DELETE',
        endpoint: ApiConstants.postReactEndpoint(postId),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.success(null, 'Reaction removed successfully');
      } else {
        return ApiResponse.error('Failed to remove reaction');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Flag post
  Future<ApiResponse<void>> flagPost(int postId) async {
    try {
      final response = await _httpService.authenticatedRequest(
        method: 'POST',
        endpoint: ApiConstants.flagPostEndpoint(postId),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(null, 'Post flagged successfully');
      } else {
        return ApiResponse.error('Failed to flag post');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
}