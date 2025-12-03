import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../providers/message_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/login_required_widget.dart';
import '../chat/chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MessageProvider>(context, listen: false).fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Si non authentifié, afficher un message
    if (authProvider.user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FE),
        body: LoginRequiredWidget(
          title: 'Messages',
          message: 'Sign in to chat with property owners and discuss details.',
          icon: Icons.message,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
          child: Column(
            children: [
              // Modern AppBar with Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: const Row(
                  children: [
                    Icon(Icons.message, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Messages',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Consumer<MessageProvider>(
                  builder: (context, messageProvider, _) {
                    final authProvider = Provider.of<AuthProvider>(context);
                    final currentUserId = authProvider.user?.id;

                    return messageProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : messageProvider.conversations.isEmpty
                            ? _buildEmptyState()
                            : RefreshIndicator(
                                onRefresh: () => messageProvider.fetchConversations(),
                                child: ListView.builder(
                                  itemCount: messageProvider.conversations.length,
                                  padding: const EdgeInsets.only(top: 16),
                                  itemBuilder: (context, index) {
                                    final conversation = messageProvider.conversations[index];
                                    final lastMessage = conversation.lastMessage;
                                    
                                    // Determine the other user in the conversation
                                    final isCurrentUserSender = lastMessage.sender.id == currentUserId;
                                    final otherUser = isCurrentUserSender 
                                        ? lastMessage.receiver 
                                        : lastMessage.sender;

                                    return Card(
                                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Dismissible(
                                        key: Key(conversation.id),
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.only(right: 20),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ),
                                        confirmDismiss: (direction) async {
                                          return await _confirmDeleteConversation(context, otherUser.name);
                                        },
                                        onDismissed: (direction) {
                                          _deleteConversation(otherUser.id);
                                        },
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          leading: CircleAvatar(
                                            radius: 28,
                                            backgroundColor: Theme.of(context).primaryColor,
                                            child: Text(
                                              otherUser.name[0].toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            otherUser.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          subtitle: Row(
                                            children: [
                                              if (isCurrentUserSender)
                                                const Icon(
                                                  Icons.done_all,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                              if (isCurrentUserSender) const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  lastMessage.content,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontWeight: conversation.unreadCount > 0 && !isCurrentUserSender
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                timeago.format(lastMessage.createdAt),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              if (conversation.unreadCount > 0 && !isCurrentUserSender)
                                                Container(
                                                  margin: const EdgeInsets.only(top: 4),
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).primaryColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Text(
                                                    '${conversation.unreadCount}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatScreen(
                                                  receiverUser: otherUser,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                  },
                ),
              ),
            ],
          ),
      ),
    );
  }

  Future<bool?> _confirmDeleteConversation(BuildContext context, String userName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: Text('Are you sure you want to delete the conversation with $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteConversation(String otherUserId) async {
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    final success = await messageProvider.deleteConversation(otherUserId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Conversation deleted successfully'
                : 'Failed to delete conversation',
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Messages Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation by contacting a property owner',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
