import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/data/chat_service.dart';
import '../../core/state/app_state_scope.dart';

/// WhatsApp-style chat screen with real-time messaging
class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _hasMarkedAsRead = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mark as read only once, after context is fully available
    if (!_hasMarkedAsRead) {
      _markAsRead();
      _hasMarkedAsRead = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _markAsRead() {
    final currentUser = AppStateScope.of(context).currentUser;
    if (currentUser != null) {
      ChatService().markMessagesAsRead(widget.chatRoomId, currentUser.id);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final currentUser = AppStateScope.of(context).currentUser;
    if (currentUser == null) return;

    _controller.clear();

    await ChatService().sendMessage(
      chatRoomId: widget.chatRoomId,
      text: text,
      senderId: currentUser.id,
      senderName: currentUser.name,
    );

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AppStateScope.of(context).currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Πρέπει να συνδεθείτε')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFEFF4FF),
              child: Text(
                widget.otherUserName.isNotEmpty 
                    ? widget.otherUserName[0].toUpperCase() 
                    : '?',
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.otherUserName,
                style: const TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list with StreamBuilder for real-time updates
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: ChatService().getMessagesStream(widget.chatRoomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Σφάλμα: ${snapshot.error}'),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ξεκινήστε τη συζήτηση!',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Auto-scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _MessageBubble(
                      message: message,
                      isMe: message.senderId == currentUser.id,
                      isSystem: message.senderId == 'system',
                    );
                  },
                );
              },
            ),
          ),

          // Message input area
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Γράψτε μήνυμα...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Message bubble widget - WhatsApp style
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool isSystem;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.isSystem,
  });

  @override
  Widget build(BuildContext context) {
    // System messages (centered, grey)
    if (isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // User messages (blue right, grey left)
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isMe ? 60 : 0,
          right: isMe ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
