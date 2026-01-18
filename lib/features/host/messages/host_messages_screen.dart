import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/data/chat_service.dart';
import '../../../core/state/app_state_scope.dart';

/// Messages screen for HOST mode - shows chats where user is the host
class HostMessagesScreen extends StatefulWidget {
  const HostMessagesScreen({super.key});

  @override
  State<HostMessagesScreen> createState() => _HostMessagesScreenState();
}

class _HostMessagesScreenState extends State<HostMessagesScreen> {
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
        title: const Text('Μηνύματα'),
        automaticallyImplyLeading: true,
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: ChatService().getChatRoomsStreamForHost(currentUser.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text('Σφάλμα: ${snapshot.error}'),
                ],
              ),
            );
          }

          final chatRooms = snapshot.data ?? [];

          if (chatRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'Δεν υπάρχουν μηνύματα',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Τα μηνύματα από τους drivers\nθα εμφανιστούν εδώ',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final room = chatRooms[index];
              return _ChatRoomTile(
                chatRoom: room,
                otherName: room.renterName,
                onTap: () {
                  context.push(Uri(
                    path: '/chat',
                    queryParameters: {
                      'id': room.id,
                      'name': room.renterName,
                    },
                  ).toString());
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// Reusable chat room tile widget
class _ChatRoomTile extends StatelessWidget {
  final ChatRoom chatRoom;
  final String otherName;
  final VoidCallback onTap;

  const _ChatRoomTile({
    required this.chatRoom,
    required this.otherName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasLastMessage = chatRoom.lastMessage != null && chatRoom.lastMessage!.isNotEmpty;
    final timeText = chatRoom.lastTimestamp != null
        ? _formatTime(chatRoom.lastTimestamp!)
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFFEF3C7),
                child: Text(
                  otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Color(0xFFD97706),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            otherName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (timeText.isNotEmpty)
                          Text(
                            timeText,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chatRoom.spotTitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasLastMessage) ...[
                      const SizedBox(height: 4),
                      Text(
                        chatRoom.lastMessage!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Χθες';
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }
}
