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

  @override
  void initState() {
    super.initState();
    ChatService().addListener(_onChatUpdate);
    // Ensure initialized
    ChatService().init();
  }

  @override
  void dispose() {
    ChatService().removeListener(_onChatUpdate);
    ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onChatUpdate() {
    if (mounted) setState(() {});
    // Scroll to bottom after frame
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
    final messages = ChatService().getMessages(widget.conversationId);
    final user = AppStateScope.of(context).currentUser;
    final myId = user?.id;

    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty 
              ? const Center(child: Text('Δεν υπάρχουν μηνύματα', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final m = messages[i];
                  // FIX: Determine if 'me' based on comparing senderId to current user's ID
                  // This works correctly for both host and driver views
                  final isMe = m.senderId == myId;
                  final isSystem = m.senderId == 'system';
                  final timeStr = DateFormat('HH:mm').format(m.timestamp);

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
                          Text(m.text, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
                          const SizedBox(height: 6),
                          Text(timeStr, style: TextStyle(color: isMe ? Colors.white70 : const Color(0xFF6B7280), fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: BorderSide.none),
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
            )
          ],
        ),
      ),
    );
  }
}
