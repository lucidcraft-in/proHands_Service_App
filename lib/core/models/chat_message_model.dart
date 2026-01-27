/// Model representing a chat message between user and service provider
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String message;
  final DateTime timestamp;
  final bool isFromCurrentUser;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.message,
    required this.timestamp,
    required this.isFromCurrentUser,
  });
}

/// Model representing a chat conversation
class ChatConversation {
  final String oderId;
  final String odherUserId;
  final String odherUserName;
  final String odherUserImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  const ChatConversation({
    required this.oderId,
    required this.odherUserId,
    required this.odherUserName,
    required this.odherUserImage,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });
}
