import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../utils/api_constants.dart';

class MessageProvider with ChangeNotifier {
  final List<Conversation> _conversations = [];
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => _conversations;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get conversations
  Future<void> fetchConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 Fetching conversations...');
      final response = await ApiService.get(
        ApiConstants.conversations,
        requiresAuth: true,
      );

      print('📦 Response: $response');
      
      if (response['success']) {
        print('✅ Success! Data count: ${(response['data'] as List).length}');
        _conversations.clear();
        _conversations.addAll(
          (response['data'] as List)
              .map((json) {
                print('📝 Parsing conversation: $json');
                return Conversation.fromJson(json);
              })
              .toList(),
        );
        print('✅ Conversations loaded: ${_conversations.length}');
      } else {
        print('❌ Response not successful: $response');
      }
    } catch (e) {
      print('❌ Error fetching conversations: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get messages
  Future<void> fetchMessages(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get(
        ApiConstants.messagesWithUser(userId),
        requiresAuth: true,
      );

      if (response['success']) {
        _messages = (response['data'] as List)
            .map((json) => Message.fromJson(json))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send message
  Future<bool> sendMessage(String receiverId, String content, {String? propertyRef}) async {
    try {
      final response = await ApiService.post(
        ApiConstants.messages,
        {
          'receiverId': receiverId,
          'content': content,
          if (propertyRef != null) 'propertyRef': propertyRef,
        },
        requiresAuth: true,
      );

      if (response['success']) {
        await fetchMessages(receiverId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Add message to list
  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  // Delete a single message
  Future<bool> deleteMessage(String messageId, String otherUserId) async {
    try {
      final response = await ApiService.delete(
        ApiConstants.deleteMessage(messageId),
        requiresAuth: true,
      );

      if (response['success']) {
        // Refresh messages after deletion
        await fetchMessages(otherUserId);
        // Refresh conversations list
        await fetchConversations();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete entire conversation
  Future<bool> deleteConversation(String otherUserId) async {
    try {
      final response = await ApiService.delete(
        ApiConstants.deleteConversation(otherUserId),
        requiresAuth: true,
      );

      if (response['success']) {
        // Clear messages
        _messages.clear();
        // Refresh conversations list
        await fetchConversations();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear messages
  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}
