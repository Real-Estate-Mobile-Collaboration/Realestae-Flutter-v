import 'user.dart';

class Message {
  final String id;
  final String conversationId;
  final User sender;
  final User receiver;
  final String content;
  final String? propertyRef;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.receiver,
    required this.content,
    this.propertyRef,
    this.isRead = false,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      sender: User.fromJson(json['sender']),
      receiver: User.fromJson(json['receiver']),
      content: json['content'] ?? '',
      propertyRef: json['propertyRef'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'conversationId': conversationId,
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
      'content': content,
      'propertyRef': propertyRef,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Conversation {
  final String id;
  final Message lastMessage;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.lastMessage,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['_id'] ?? '',
      lastMessage: Message.fromJson(json['lastMessage']),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
