class User {
  final int id;
  final String username;
  final String email;
  final String name;
  final String bio;
  final String? profilePicture;
  final String? profilePictureUrl;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.bio,
    this.profilePicture,
    this.profilePictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      profilePicture: json['profile_picture'],
      profilePictureUrl: json['profile_picture_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': id,
      'username': username,
      'email': email,
      'name': name,
      'bio': bio,
      'profile_picture': profilePicture,
      'profile_picture_url': profilePictureUrl,
    };
  }
}