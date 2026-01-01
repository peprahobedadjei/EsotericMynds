class Post {
  final int id;
  final PostUser user;
  final String content;
  final String createdAt;
  final int deepCount;
  final int shallowCount;
  final int flagCount;
  final bool isRemoved;
  final bool isLiked;
  final bool isFlagged;
  final String? userReaction;
  final String? mediaUrl;
  final PostRoom room;

  Post({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
    required this.deepCount,
    required this.shallowCount,
    required this.flagCount,
    required this.isRemoved,
    required this.isLiked,
    required this.isFlagged,
    this.userReaction,
    this.mediaUrl,
    required this.room,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      user: PostUser.fromJson(json['user']),
      content: json['content'] ?? '',
      createdAt: json['created_at'],
      deepCount: json['deep_count'] ?? 0,
      shallowCount: json['shallow_count'] ?? 0,
      flagCount: json['flag_count'] ?? 0,
      isRemoved: json['is_removed'] ?? false,
      isLiked: json['is_liked'] ?? false,
      isFlagged: json['is_flagged'] ?? false,
      userReaction: json['user_reaction'],
      mediaUrl: json['media_url'],
      room: PostRoom.fromJson(json['room']),
    );
  }
}

class PostUser {
  final int id;
  final String username;
  final String? profilePictureUrl;

  PostUser({
    required this.id,
    required this.username,
    this.profilePictureUrl,
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      id: json['id'],
      username: json['username'],
      profilePictureUrl: json['profile_picture_url'] ?? json['profile_picture'],
    );
  }
}

class PostRoom {
  final int id;
  final String name;
  final List<RoomMember> members;

  PostRoom({
    required this.id,
    required this.name,
    required this.members,
  });

  factory PostRoom.fromJson(Map<String, dynamic> json) {
    return PostRoom(
      id: json['id'],
      name: json['name'],
      members: (json['members'] as List)
          .map((m) => RoomMember.fromJson(m))
          .toList(),
    );
  }
}

class RoomMember {
  final int id;
  final String username;

  RoomMember({
    required this.id,
    required this.username,
  });

  factory RoomMember.fromJson(Map<String, dynamic> json) {
    return RoomMember(
      id: json['id'],
      username: json['username'],
    );
  }
}