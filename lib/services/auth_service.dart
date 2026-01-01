import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'http_service.dart';
import 'storage_service.dart';

class AuthService {
  final _httpService = HttpService();
  final _storage = StorageService();

  // Login
  Future<ApiResponse<AuthResponse>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _httpService.request(
        method: 'POST',
        endpoint: ApiConstants.loginEndpoint,
        headers: {'Content-Type': 'application/json'},
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        
        return ApiResponse.success(
          authResponse,
          'Login successful',
        );
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
          error['detail'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Register
  Future<ApiResponse<AuthResponse>> register({
    required String name,
    required String username,
    required String email,
    required String password,
    File? profilePicture,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}'),
      );

      // Add form fields
      request.fields['name'] = name;
      request.fields['username'] = username;
      request.fields['email'] = email;
      request.fields['password'] = password;

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        
        return ApiResponse.success(
          authResponse,
          'Registration successful',
        );
      } else {
        final error = jsonDecode(response.body);
        
        // Handle field-specific errors
        if (error is Map<String, dynamic>) {
          String errorMessage = '';
          error.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessage += '${key.toUpperCase()}: ${value[0]}\n';
            }
          });
          return ApiResponse.error(
            errorMessage.isNotEmpty ? errorMessage : 'Registration failed',
            errors: error,
          );
        }
        
        return ApiResponse.error('Registration failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Get User Profile
  Future<ApiResponse<User>> getProfile() async {
    try {
      final response = await _httpService.authenticatedRequest(
        method: 'GET',
        endpoint: ApiConstants.profileEndpoint,
      );

      print('GET Profile status: ${response.statusCode}');
      print('GET Profile response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('GET Profile data: $data');
        
        final user = User.fromJson(data);
        print('User from GET profile: username=${user.username}, profileUrl=${user.profilePictureUrl}');
        
        return ApiResponse.success(user, 'Profile fetched successfully');
      } else {
        return ApiResponse.error('Failed to fetch profile');
      }
    } catch (e) {
      print('GET Profile error: $e');
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.clearAll();
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _storage.getAccessToken() != null;
  }
}