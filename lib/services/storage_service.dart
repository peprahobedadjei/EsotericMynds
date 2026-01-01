import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token Management
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs?.setString(StorageKeys.accessToken, accessToken);
    await _prefs?.setString(StorageKeys.refreshToken, refreshToken);
  }

  String? getAccessToken() {
    return _prefs?.getString(StorageKeys.accessToken);
  }

  String? getRefreshToken() {
    return _prefs?.getString(StorageKeys.refreshToken);
  }

  Future<void> clearTokens() async {
    await _prefs?.remove(StorageKeys.accessToken);
    await _prefs?.remove(StorageKeys.refreshToken);
  }

  // User Data Management
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs?.setInt(StorageKeys.userId, userData['user'] ?? 0);
    await _prefs?.setString(StorageKeys.username, userData['username'] ?? '');
    await _prefs?.setString(StorageKeys.email, userData['email'] ?? '');
    await _prefs?.setString(StorageKeys.name, userData['name'] ?? '');
    await _prefs?.setString(StorageKeys.bio, userData['bio'] ?? '');
    await _prefs?.setString(
      StorageKeys.profilePicture,
      userData['profile_picture_url'] ?? '',
    );
  }

  Map<String, dynamic>? getUserData() {
    final userId = _prefs?.getInt(StorageKeys.userId);
    if (userId == null) return null;

    return {
      'user': userId,
      'username': _prefs?.getString(StorageKeys.username) ?? '',
      'email': _prefs?.getString(StorageKeys.email) ?? '',
      'name': _prefs?.getString(StorageKeys.name) ?? '',
      'bio': _prefs?.getString(StorageKeys.bio) ?? '',
      'profile_picture_url': _prefs?.getString(StorageKeys.profilePicture) ?? '',
    };
  }

  Future<void> clearUserData() async {
    await _prefs?.remove(StorageKeys.userId);
    await _prefs?.remove(StorageKeys.username);
    await _prefs?.remove(StorageKeys.email);
    await _prefs?.remove(StorageKeys.name);
    await _prefs?.remove(StorageKeys.bio);
    await _prefs?.remove(StorageKeys.profilePicture);
  }

  Future<void> clearAll() async {
    await clearTokens();
    await clearUserData();
  }

  // Theme Management
  Future<void> setDarkMode(bool isDark) async {
    await _prefs?.setBool(StorageKeys.isDarkMode, isDark);
  }

  bool isDarkMode() {
    return _prefs?.getBool(StorageKeys.isDarkMode) ?? false;
  }

  Future<void> setThemeColorIndex(int index) async {
    await _prefs?.setInt(StorageKeys.themeColorIndex, index);
  }

  int getThemeColorIndex() {
    return _prefs?.getInt(StorageKeys.themeColorIndex) ?? 0;
  }

  // Terms Agreement
  Future<void> setAgreedToTerms(bool agreed) async {
    await _prefs?.setBool(StorageKeys.agreedToTerms, agreed);
  }

  bool hasAgreedToTerms() {
    return _prefs?.getBool(StorageKeys.agreedToTerms) ?? false;
  }
}