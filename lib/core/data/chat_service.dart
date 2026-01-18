import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Message model for individual chat messages
class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  factory ChatMessage.fromFirestore(String id, Map<String, dynamic> data) {
    return ChatMessage(
      id: id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'User',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }
}

/// Chat room model representing a conversation between host and renter
class ChatRoom {
  final String id;
  final String spotId;
  final String spotTitle;
  final String hostId;
  final String hostName;
  final String renterId;
  final String renterName;
  final String? lastMessage;
  final DateTime? lastTimestamp;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.spotId,
    required this.spotTitle,
    required this.hostId,
    required this.hostName,
    required this.renterId,
    required this.renterName,
    this.lastMessage,
    this.lastTimestamp,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'spotId': spotId,
      'spotTitle': spotTitle,
      'hostId': hostId,
      'hostName': hostName,
      'renterId': renterId,
      'renterName': renterName,
      'lastMessage': lastMessage,
      'lastTimestamp': lastTimestamp != null ? Timestamp.fromDate(lastTimestamp!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ChatRoom.fromFirestore(String id, Map<String, dynamic> data) {
    return ChatRoom(
      id: id,
      spotId: data['spotId'] ?? '',
      spotTitle: data['spotTitle'] ?? '',
      hostId: data['hostId'] ?? '',
      hostName: data['hostName'] ?? '',
      renterId: data['renterId'] ?? '',
      renterName: data['renterName'] ?? '',
      lastMessage: data['lastMessage'],
      lastTimestamp: (data['lastTimestamp'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Chat Service - manages all chat room and messaging operations
class ChatService extends ChangeNotifier {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  /// Collection reference for chat rooms
  CollectionReference<Map<String, dynamic>> get _chatRoomsRef => 
      _db.collection('chat_rooms');

  /// Generate composite chat room ID: spotId_hostId_renterId
  /// This ensures a unique chat for every specific rental
  static String getChatRoomId({
    required String spotId,
    required String hostId,
    required String renterId,
  }) {
    return '${spotId}_${hostId}_$renterId';
  }

  /// Get or create a chat room for a specific spot/host/renter combination
  Future<ChatRoom> getOrCreateChatRoom({
    required String spotId,
    required String spotTitle,
    required String hostId,
    required String hostName,
    required String renterId,
    required String renterName,
  }) async {
    final chatRoomId = getChatRoomId(
      spotId: spotId,
      hostId: hostId,
      renterId: renterId,
    );

    final docRef = _chatRoomsRef.doc(chatRoomId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      return ChatRoom.fromFirestore(chatRoomId, docSnapshot.data()!);
    }

    // Create new chat room
    final now = DateTime.now();
    final chatRoom = ChatRoom(
      id: chatRoomId,
      spotId: spotId,
      spotTitle: spotTitle,
      hostId: hostId,
      hostName: hostName,
      renterId: renterId,
      renterName: renterName,
      createdAt: now,
    );

    await docRef.set(chatRoom.toFirestore());

    // Send initial system message
    await _sendSystemMessage(
      chatRoomId: chatRoomId,
      text: '💬 Νέα συνομιλία για "$spotTitle". Καλή επικοινωνία!',
    );

    return chatRoom;
  }

  /// Send a system message (for initial chat creation, etc.)
  Future<void> _sendSystemMessage({
    required String chatRoomId,
    required String text,
  }) async {
    final message = ChatMessage(
      id: '',
      text: text,
      senderId: 'system',
      senderName: 'ParkNow',
      timestamp: DateTime.now(),
    );

    await _chatRoomsRef
        .doc(chatRoomId)
        .collection('messages')
        .add(message.toFirestore());
  }

  /// Send a message in a chat room
  Future<void> sendMessage({
    required String chatRoomId,
    required String text,
    required String senderId,
    required String senderName,
  }) async {
    final message = ChatMessage(
      id: '',
      text: text,
      senderId: senderId,
      senderName: senderName,
      timestamp: DateTime.now(),
    );

    // Add message to subcollection
    await _chatRoomsRef
        .doc(chatRoomId)
        .collection('messages')
        .add(message.toFirestore());

    // Update parent document with last message info
    await _chatRoomsRef.doc(chatRoomId).update({
      'lastMessage': text,
      'lastTimestamp': Timestamp.now(),
    });

    notifyListeners();
  }

  /// Stream messages for a specific chat room (for real-time updates)
  Stream<List<ChatMessage>> getMessagesStream(String chatRoomId) {
    return _chatRoomsRef
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Get all chat rooms where user is the HOST (for host mode)
  Future<List<ChatRoom>> getChatRoomsForHost(String userId) async {
    try {
      final querySnapshot = await _chatRoomsRef
          .where('hostId', isEqualTo: userId)
          .orderBy('lastTimestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ChatRoom.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching host chat rooms: $e');
      // Fallback without ordering if index doesn't exist
      try {
        final querySnapshot = await _chatRoomsRef
            .where('hostId', isEqualTo: userId)
            .get();

        final rooms = querySnapshot.docs
            .map((doc) => ChatRoom.fromFirestore(doc.id, doc.data()))
            .toList();
        
        // Sort locally
        rooms.sort((a, b) => (b.lastTimestamp ?? b.createdAt)
            .compareTo(a.lastTimestamp ?? a.createdAt));
        
        return rooms;
      } catch (e2) {
        debugPrint('Fallback also failed: $e2');
        return [];
      }
    }
  }

  /// Get all chat rooms where user is the RENTER (for driver mode)
  Future<List<ChatRoom>> getChatRoomsForRenter(String userId) async {
    try {
      final querySnapshot = await _chatRoomsRef
          .where('renterId', isEqualTo: userId)
          .orderBy('lastTimestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ChatRoom.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching renter chat rooms: $e');
      // Fallback without ordering if index doesn't exist
      try {
        final querySnapshot = await _chatRoomsRef
            .where('renterId', isEqualTo: userId)
            .get();

        final rooms = querySnapshot.docs
            .map((doc) => ChatRoom.fromFirestore(doc.id, doc.data()))
            .toList();
        
        // Sort locally
        rooms.sort((a, b) => (b.lastTimestamp ?? b.createdAt)
            .compareTo(a.lastTimestamp ?? a.createdAt));
        
        return rooms;
      } catch (e2) {
        debugPrint('Fallback also failed: $e2');
        return [];
      }
    }
  }

  /// Stream chat rooms for host (real-time updates)
  Stream<List<ChatRoom>> getChatRoomsStreamForHost(String userId) {
    return _chatRoomsRef
        .where('hostId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final rooms = snapshot.docs
              .map((doc) => ChatRoom.fromFirestore(doc.id, doc.data()))
              .toList();
          rooms.sort((a, b) => (b.lastTimestamp ?? b.createdAt)
              .compareTo(a.lastTimestamp ?? a.createdAt));
          return rooms;
        });
  }

  /// Stream chat rooms for renter (real-time updates)
  Stream<List<ChatRoom>> getChatRoomsStreamForRenter(String userId) {
    return _chatRoomsRef
        .where('renterId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final rooms = snapshot.docs
              .map((doc) => ChatRoom.fromFirestore(doc.id, doc.data()))
              .toList();
          rooms.sort((a, b) => (b.lastTimestamp ?? b.createdAt)
              .compareTo(a.lastTimestamp ?? a.createdAt));
          return rooms;
        });
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId, String readerId) async {
    final unreadMessages = await _chatRoomsRef
        .doc(chatRoomId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unreadMessages.docs) {
      // Only mark as read if the reader is NOT the sender
      if (doc.data()['senderId'] != readerId) {
        await doc.reference.update({'isRead': true});
      }
    }
  }

  /// Check if user can message this spot (prevents self-messaging)
  bool canMessageSpot({
    required String currentUserId,
    required String spotOwnerId,
  }) {
    return currentUserId != spotOwnerId;
  }
}
