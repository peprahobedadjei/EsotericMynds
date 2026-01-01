import 'dart:convert';
import '../models/api_response.dart';
import '../utils/constants.dart';
import 'http_service.dart';

class UserProfileService {
  final _httpService = HttpService();

  // Cache to store fetched user profiles
  static final Map<int, UserProfile> _profileCache = {};

  // Follow user to get their profile info
  Future<ApiResponse<UserProfile>> getUserProfile(int userId) async {
    // Check cache first
    if (_profileCache.containsKey(userId)) {
      return ApiResponse.success(
        _profileCache[userId]!,
        'Profile loaded from cache',
      );
    }

    try {
      final response = await _httpService.authenticatedRequest(
        method: 'POST',
        endpoint: '/api/follow/$userId/',
      );

      print('Get user profile status: ${response.statusCode}');
      print('Get user profile response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Extract followed_user from response
        final followedUser = data['followed_user'];
        
        final profile = UserProfile.fromJson(followedUser);
        
        // Cache the profile
        _profileCache[userId] = profile;
        
        return ApiResponse.success(profile, data['message'] ?? 'Profile fetched');
      } else {
        return ApiResponse.error('Failed to fetch user profile');
      }
    } catch (e) {
      print('Get user profile error: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Clear cache
  static void clearCache() {
    _profileCache.clear();
  }
}

// UserProfile model
class UserProfile {
  final int id;
  final String username;
  final String name;
  final String bio;
  final String? profilePictureUrl;

  UserProfile({
    required this.id,
    required this.username,
    required this.name,
    required this.bio,
    this.profilePictureUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      profilePictureUrl: json['profile_picture_url'],
    );
  }
}