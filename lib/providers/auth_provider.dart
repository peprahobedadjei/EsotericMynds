import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/profile_service.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();
  final _storage = StorageService();
  final _profileService = ProfileService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _authService.isLoggedIn();

  // Load user from storage
  Future<void> loadUser() async {
    final userData = _storage.getUserData();
    print('Loading user from SharedPreferences: $userData');
    if (userData != null) {
      _currentUser = User.fromJson(userData);
      print('Loaded user: username=${_currentUser?.username}, profileUrl=${_currentUser?.profilePictureUrl}');
      notifyListeners();
    } else {
      print('No user data in SharedPreferences');
    }
  }

  // Login
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.login(
      username: username,
      password: password,
    );

    _isLoading = false;

    if (response.success && response.data != null) {
      // Save tokens
      await _storage.saveTokens(
        accessToken: response.data!.accessToken!,
        refreshToken: response.data!.refreshToken!,
      );

      // Fetch and save user profile
      await fetchProfile();
      
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String username,
    required String email,
    required String password,
    File? profilePicture,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.register(
      name: name,
      username: username,
      email: email,
      password: password,
      profilePicture: profilePicture,
    );

    _isLoading = false;

    if (response.success && response.data != null) {
      // Save tokens
      await _storage.saveTokens(
        accessToken: response.data!.accessToken!,
        refreshToken: response.data!.refreshToken!,
      );

      // Fetch and save user profile
      await fetchProfile();
      
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  // Fetch Profile
  Future<void> fetchProfile() async {
    print('Fetching profile from API...');
    final response = await _authService.getProfile();

    print('fetchProfile response: success=${response.success}');
    if (response.success && response.data != null) {
      print('Profile data received: username=${response.data!.username}, email=${response.data!.email}');
      _currentUser = response.data;
      
      final userJson = response.data!.toJson();
      print('Saving to SharedPreferences: $userJson');
      await _storage.saveUserData(userJson);
      
      print('Profile saved successfully');
      notifyListeners();
    } else {
      print('Failed to fetch profile: ${response.message}');
    }
  }

  // Update Profile
  Future<bool> updateProfile({
    required String name,
    required String username,
    required String email,
    required String bio,
    File? profilePicture,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _profileService.updateProfile(
      name: name,
      username: username,
      email: email,
      bio: bio,
      profilePicture: profilePicture,
    );

    _isLoading = false;

    if (response.success && response.data != null) {
      // Update current user in memory
      _currentUser = response.data;
      
      // Save to SharedPreferences
      final userJson = response.data!.toJson();
      print('Saving to SharedPreferences: $userJson');
      await _storage.saveUserData(userJson);
      
      print('AuthProvider - Updated user: ${_currentUser?.username}');
      print('AuthProvider - Profile URL: ${_currentUser?.profilePictureUrl}');
      
      // Notify all listeners to rebuild
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  // Delete Account
  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _profileService.deleteAccount();

    _isLoading = false;

    if (response.success) {
      await _storage.clearAll();
      _currentUser = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get access token for direct API calls
  Future<String?> getAccessToken() async {
    return _storage.getAccessToken();
  }
}