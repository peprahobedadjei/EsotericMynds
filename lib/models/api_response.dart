class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.success(T data, String message) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
    );
  }

  factory ApiResponse.error(String message, {Map<String, dynamic>? errors}) {
    return ApiResponse(
      success: false,
      message: message,
      errors: errors,
    );
  }
}

class AuthResponse {
  final String? accessToken;
  final String? refreshToken;
  final Map<String, dynamic>? user;

  AuthResponse({
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access'],
      refreshToken: json['refresh'],
      user: json['user'],
    );
  }
}