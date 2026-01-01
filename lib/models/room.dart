class Room {
  final int id;
  final String name;
  final List<RoomMember> members;

  Room({
    required this.id,
    required this.name,
    required this.members,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
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