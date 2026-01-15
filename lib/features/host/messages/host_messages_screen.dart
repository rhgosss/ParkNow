import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/chat_service.dart';
import '../../../../core/state/app_state_scope.dart';

class HostMessagesScreen extends StatefulWidget {
  const HostMessagesScreen({super.key});

  @override
  State<HostMessagesScreen> createState() => _HostMessagesScreenState();
}

class _HostMessagesScreenState extends State<HostMessagesScreen> {
  @override
  void initState() {
    super.initState();
    ChatService().addListener(_refresh);
  }

  @override
  void dispose() {
    ChatService().removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AppStateScope.of(context).currentUser;
    if (currentUser == null) return const Scaffold(body: Center(child: Text('Error')));

    final conversationIds = ChatService().getConversationsForUser(currentUser.id);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Μηνύματα'),
      ),
      body: SafeArea(
        child: conversationIds.isEmpty 
        ? const Center(child: Text('Δεν υπάρχουν μηνύματα'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: conversationIds.length,
            itemBuilder: (context, index) {
              final convId = conversationIds[index];
              final messages = ChatService().getMessages(convId);
              if (messages.isEmpty) return const SizedBox.shrink();

              // Get last message
              final lastMsg = messages.last; // Assumes sorted by timestamp ascending
              
              // Find other user name
              String otherName = 'Driver';
              // Check if there is a message from someone else
              final otherMsg = messages.firstWhere(
                (m) => m.senderId != currentUser.id, 
                orElse: () => messages.first
              );
              
              if (otherMsg.senderId != currentUser.id) {
                otherName = otherMsg.senderName;
              } else {
                 // Try to guess from ID? 
                 // convId = driverId_hostId
                 // if currentUser.id == hostId, then driverId is first part
                 final parts = convId.split('_');
                 if (parts.length == 2) {
                    if (currentUser.id == parts[1]) otherName = 'Driver'; 
                    // If we never received a message from them, we might not know the name. 
                    // In real app we fetch user profile. 
                 }
              }

              return InkWell(
                onTap: () {
                   context.push(Uri(path: '/chat', queryParameters: {'id': convId, 'name': otherName}).toString());
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFEFF4FF),
                        child: Text(otherName[0].toUpperCase()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(otherName, style: const TextStyle(fontWeight: FontWeight.w700))),
                                Text(
                                  "${lastMsg.timestamp.day}/${lastMsg.timestamp.month} ${lastMsg.timestamp.hour}:${lastMsg.timestamp.minute}", 
                                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(lastMsg.text, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool active;
  const _Chip({required this.text, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.black87)),
    );
  }
}
