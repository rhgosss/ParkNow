import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/data/chat_service.dart';
import '../../core/state/app_state_scope.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserName;
  
  const ChatScreen({
    super.key, 
    this.conversationId = 'default',
    this.otherUserName = 'Chat',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    // Only call ChatService.init() here - it doesn't need context
    ChatService().init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Move context-dependent initialization here (runs once)
    if (!_didInit) {
      _didInit = true;
      _markAsRead();
    }
  }

  @override
  void dispose() {
    ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _markAsRead() {
    final user = AppStateScope.of(context).currentUser;
    if (user != null) {
      ChatService().markMessagesAsRead(widget.conversationId, user.id);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> send() async {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;

    final user = AppStateScope.of(context).currentUser;
    final senderId = user?.id ?? 'guest';
    final senderName = user?.name ?? 'Guest';

    ctrl.clear();
    await ChatService().sendMessage(text, senderId, senderName, widget.conversationId);
  }

  @override
  Widget build(BuildContext context) {
    final user = AppStateScope.of(context).currentUser;
    final myId = user?.id;

    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              // Use StreamBuilder for real-time updates
              child: StreamBuilder<List<ChatMessage>>(
                stream: ChatService().getMessagesStream(widget.conversationId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final messages = snapshot.data ?? [];
                  
                  if (messages.isEmpty) {
                    return const Center(
                      child: Text('Δεν υπάρχουν μηνύματα', style: TextStyle(color: Colors.grey)),
                    );
                  }
                  
                  // Scroll to bottom when new messages arrive
                  _scrollToBottom();
                  
                  return ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final m = messages[i];
                      final isMe = m.senderId == myId;
                      final isSystem = m.senderId == 'system';
                      final timeStr = DateFormat('HH:mm').format(m.timestamp);

                      // System messages - centered and styled differently
                      if (isSystem) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                m.text,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(maxWidth: 280),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF2563EB) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Show sender name for received messages
                              if (!isMe) ...[
                                Text(
                                  m.senderName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(m.text, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    timeStr, 
                                    style: TextStyle(
                                      color: isMe ? Colors.white70 : const Color(0xFF6B7280), 
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      m.isRead ? Icons.done_all : Icons.done,
                                      size: 14,
                                      color: m.isRead ? Colors.lightBlueAccent : Colors.white70,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Input area
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      onSubmitted: (_) => send(),
                      decoration: InputDecoration(
                        hintText: 'Γράψε μήνυμα...',
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26), 
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF2563EB),
                    child: IconButton(
                      onPressed: send,
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
