import 'package:flutter/material.dart';

// API Configuration
class ApiConstants {
  static const String baseUrl = 'https://deepthinkers-5fb35d27dd37.herokuapp.com';
  static const String loginEndpoint = '/api/login/';
  static const String registerEndpoint = '/api/register/';
  static const String profileEndpoint = '/api/profile/';
  static const String refreshTokenEndpoint = '/api/token/refresh/';
  static const String roomsEndpoint = '/api/rooms/';
  static const String postsEndpoint = '/api/posts/';
  static const String deleteAccountEndpoint = '/api/delete-account/';
  
  // Dynamic endpoints
  static String postReactEndpoint(int postId) => '/api/posts/$postId/react/';
  static String flagPostEndpoint(int postId) => '/api/posts/$postId/flag/';
  static String joinRoomEndpoint(int roomId) => '/api/rooms/$roomId/join/';
}

// App Colors
class AppColors {
  // Static colors that don't change
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color greyText = Color(0xFF888888);
  static const Color errorRed = Color(0xFFE74C3C);
  static const Color successGreen = Color(0xFF2ECC71);
  
  // Dynamic primary color - use themeProvider.primaryColor instead
  static const Color primaryOrange = Color(0xFFFF6B35); // Fallback only
  
  // Theme color options
  static const List<Color> themeColors = [
    Color(0xFFFF6B35), // Orange (default)
    Color(0xFFE74C3C), // Red
    Color(0xFF3498DB), // Blue
    Color(0xFF2ECC71), // Green
    Color(0xFF9B59B6), // Purple
    Color(0xFFF39C12), // Yellow
    Color(0xFF1ABC9C), // Teal
    Color(0xFFE91E63), // Pink
    Color(0xFF00BCD4), // Cyan
    Color(0xFF8E44AD), // Dark Purple
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF607D8B), // Blue Grey
  ];
  
  static const List<String> themeColorNames = [
    'Orange',
    'Red',
    'Blue',
    'Green',
    'Purple',
    'Yellow',
    'Teal',
    'Pink',
    'Cyan',
    'Violet',
    'Coral',
    'Slate',
  ];
}

// Storage Keys
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String username = 'username';
  static const String email = 'email';
  static const String name = 'name';
  static const String bio = 'bio';
  static const String profilePicture = 'profile_picture';
  static const String isDarkMode = 'is_dark_mode';
  static const String agreedToTerms = 'agreed_to_terms';
  static const String themeColorIndex = 'theme_color_index';
}