// lib/features/booking/active_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/data/parking_service.dart';
import '../../../core/data/chat_service.dart';
import '../../../core/state/app_state_scope.dart';

class ActiveBookingScreen extends StatelessWidget {
  final String? bookingId;
  const ActiveBookingScreen({super.key, this.bookingId});

  @override
  Widget build(BuildContext context) {
    final bookings = ParkingService().bookings;
    
    // Find specific booking or get most recent
    Booking? activeBooking;
    if (bookingId != null) {
      try {
        activeBooking = bookings.firstWhere((b) => b.id == bookingId);
      } catch (_) {}
    } else {
      // Fallback: get most recent active booking
      final now = DateTime.now();
      final active = bookings.where((b) => b.endTime.isAfter(now)).toList();
      activeBooking = active.isNotEmpty ? active.last : null;
    }

    if (activeBooking == null) {
       return Scaffold(
         appBar: AppBar(leading: const BackButton(), title: const Text('Δεν βρέθηκε κράτηση')),
         body: Center(
           child: ElevatedButton(onPressed: () => context.go('/main'), child: const Text('Επιστροφή')),
         ),
       );
    }

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Ενεργή Κράτηση')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PIN Πρόσβασης', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(activeBooking.pinCode, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('Για το: ${activeBooking.spot.title}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(activeBooking.spot.subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  const SizedBox(height: 8),
                  Text(
                    '${dateFormat.format(activeBooking.startTime)} - ${dateFormat.format(activeBooking.endTime)}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Δείξ\' το στον host ή χρησιμοποίησέ το στο keypad.', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Σύνολο', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '€${activeBooking.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
             const SizedBox(height: 14),
            SizedBox(
              height: 54,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final user = AppStateScope.of(context).currentUser;
                  if (user != null && activeBooking != null) {
                    // First ensure chat room exists, then navigate
                    final chatRoom = await ChatService().getOrCreateChatRoom(
                      spotId: activeBooking.spot.id,
                      spotTitle: activeBooking.spot.title,
                      hostId: activeBooking.spot.ownerId ?? 'unknown',
                      hostName: activeBooking.spot.ownerName,
                      renterId: user.id,
                      renterName: user.name,
                    );
                    if (context.mounted) {
                      context.push(Uri(path: '/chat', queryParameters: {
                        'id': chatRoom.id, 
                        'name': activeBooking.spot.ownerName,
                      }).toString());
                    }
                  }
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Μήνυμα στον Host'),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 54,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/main'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: const Text('Πίσω στην αρχική', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
