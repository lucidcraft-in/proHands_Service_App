import 'chat_message_model.dart';

/// Service for managing chat messages (uses dummy data)
class ChatService {
  // Singleton pattern
  ChatService._();
  static final ChatService instance = ChatService._();

  // Store messages in memory (keyed by conversation id)
  final Map<String, List<ChatMessage>> _conversations = {};

  /// Get messages for a conversation between two users
  List<ChatMessage> getMessages(String currentUserId, String otherUserId) {
    final conversationId = _getConversationId(currentUserId, otherUserId);

    // Return existing messages or create sample conversation
    if (!_conversations.containsKey(conversationId)) {
      _conversations[conversationId] = _createSampleMessages(
        currentUserId,
        otherUserId,
      );
    }

    return _conversations[conversationId]!;
  }

  /// Send a new message
  void sendMessage({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
    required String message,
  }) {
    final conversationId = _getConversationId(currentUserId, otherUserId);

    if (!_conversations.containsKey(conversationId)) {
      _conversations[conversationId] = [];
    }

    final newMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: currentUserId,
      senderName: currentUserName,
      receiverId: otherUserId,
      receiverName: otherUserName,
      message: message,
      timestamp: DateTime.now(),
      isFromCurrentUser: true,
    );

    _conversations[conversationId]!.add(newMessage);
  }

  /// Generate a consistent conversation ID for two users
  String _getConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Create sample messages for demo
  List<ChatMessage> _createSampleMessages(
    String currentUserId,
    String otherUserId,
  ) {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: 'msg_1',
        senderId: otherUserId,
        senderName: 'Service Provider',
        receiverId: currentUserId,
        receiverName: 'Customer',
        message: 'Hello! I received your booking request.',
        timestamp: now.subtract(const Duration(hours: 2)),
        isFromCurrentUser: false,
      ),
      ChatMessage(
        id: 'msg_2',
        senderId: currentUserId,
        senderName: 'Customer',
        receiverId: otherUserId,
        receiverName: 'Service Provider',
        message: 'Hi! Yes, I need help with cleaning service.',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 55)),
        isFromCurrentUser: true,
      ),
      ChatMessage(
        id: 'msg_3',
        senderId: otherUserId,
        senderName: 'Service Provider',
        receiverId: currentUserId,
        receiverName: 'Customer',
        message: 'Sure! I can come tomorrow at 10 AM. Does that work for you?',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 50)),
        isFromCurrentUser: false,
      ),
      ChatMessage(
        id: 'msg_4',
        senderId: currentUserId,
        senderName: 'Customer',
        receiverId: otherUserId,
        receiverName: 'Service Provider',
        message: 'That sounds perfect! See you then.',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
        isFromCurrentUser: true,
      ),
    ];
  }
}
