class ChatMessage {
  final int id;
  final ChatUser sender;
  final int receiver;
  final String content;
  final String timestamp;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      sender: ChatUser.fromJson(json['sender']),
      receiver: json['receiver'],
      content: json['content'],
      timestamp: json['timestamp'],
    );
  }
}

class ChatUser {
  final int id;
  final String username;

  ChatUser({
    required this.id,
    required this.username,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      username: json['username'],
    );
  }
}