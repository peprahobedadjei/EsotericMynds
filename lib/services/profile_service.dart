import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'http_service.dart';
import 'storage_service.dart';

class ProfileService {
  final _httpService = HttpService();
  final _storage = StorageService();

  // Update profile
  Future<ApiResponse<User>> updateProfile({
    required String name,
    required String username,
    required String email,
    required String bio,
    File? profilePicture,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profileEndpoint}'),
      );

      // Get access token
      final accessToken = _storage.getAccessToken();
      if (accessToken == null) {
        return ApiResponse.error('No access token found');
      }

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $accessToken';

      // Add form fields
      request.fields['name'] = name;
      request.fields['username'] = username;
      request.fields['email'] = email;
      request.fields['bio'] = bio;

      // Add profile picture if available
      if (profilePicture != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_picture',
            profilePicture.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Update profile status: ${response.statusCode}');
      print('Update profile response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Full API response: $data');
        
        // The API returns: {"message": "...", "profile": {...}}
        // We need to extract the "profile" object
        final profileData = data['profile'];
        print('Profile data: $profileData');
        print('Profile picture URL: ${profileData['profile_picture_url']}');
        
        final user = User.fromJson(profileData);
        print('User object created with profile URL: ${user.profilePictureUrl}');
        
        return ApiResponse.success(user, data['message'] ?? 'Profile updated successfully');
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Failed to update profile';
        
        if (errorData is Map) {
          if (errorData.containsKey('detail')) {
            errorMessage = errorData['detail'];
          } else {
            errorMessage = errorData.entries
                .map((e) => '${e.key}: ${e.value}')
                .join(', ');
          }
        }
        
        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      print('Update profile error: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Delete account
  Future<ApiResponse<void>> deleteAccount() async {
    try {
      final response = await _httpService.authenticatedRequest(
        method: 'DELETE',
        endpoint: ApiConstants.deleteAccountEndpoint,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.success(null, 'Account deleted successfully');
      } else {
        return ApiResponse.error('Failed to delete account');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Join room
  Future<ApiResponse<void>> joinRoom(int roomId) async {
    try {
      final response = await _httpService.authenticatedRequest(
        method: 'POST',
        endpoint: ApiConstants.joinRoomEndpoint(roomId),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(null, 'Joined room successfully');
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Failed to join room';
        
        if (errorData is Map && errorData.containsKey('detail')) {
          errorMessage = errorData['detail'];
        }
        
        return ApiResponse.error(errorMessage);
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
}