import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'storage_service.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  final _storage = StorageService();

  // Get access token (for multipart requests)
  Future<String?> getAccessToken() async {
    return _storage.getAccessToken();
  }

  // Make authenticated request with automatic token refresh
  Future<http.Response> authenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final accessToken = _storage.getAccessToken();
    
    if (accessToken == null) {
      throw Exception('No access token found');
    }

    final authHeaders = {
      'Authorization': 'Bearer $accessToken',
      ...?headers,
    };

    http.Response response;

    try {
      response = await _makeRequest(
        method: method,
        url: '${ApiConstants.baseUrl}$endpoint',
        headers: authHeaders,
        body: body,
      );

      // Check if token is expired
      if (response.statusCode == 401 || response.statusCode == 403) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'token_not_valid') {
          // Try to refresh token
          final refreshed = await _refreshAccessToken();
          
          if (refreshed) {
            // Retry original request with new token
            final newAccessToken = _storage.getAccessToken();
            authHeaders['Authorization'] = 'Bearer $newAccessToken';
            
            response = await _makeRequest(
              method: method,
              url: '${ApiConstants.baseUrl}$endpoint',
              headers: authHeaders,
              body: body,
            );
          } else {
            throw Exception('Token refresh failed');
          }
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Refresh access token
  Future<bool> _refreshAccessToken() async {
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
      return false;
    }
  }

  // Make HTTP request
  Future<http.Response> _makeRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final uri = Uri.parse(url);

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(uri, headers: headers);
      case 'POST':
        if (headers?['Content-Type'] == 'application/json') {
          return await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
        } else {
          return await http.post(uri, headers: headers, body: body);
        }
      case 'PUT':
        return await http.put(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
      case 'DELETE':
        return await http.delete(uri, headers: headers);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  // Public method for non-authenticated requests
  Future<http.Response> request({
    required String method,
    required String endpoint,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return await _makeRequest(
      method: method,
      url: '${ApiConstants.baseUrl}$endpoint',
      headers: headers,
      body: body,
    );
  }
}