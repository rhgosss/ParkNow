// lib/features/booking/my_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/data/parking_service.dart';
import '../../core/state/app_state_scope.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AppStateScope.of(context).currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Οι Κρατήσεις μου')),
        body: const Center(child: Text('Πρέπει να συνδεθείτε')),
      );
    }

    final allBookings = ParkingService().getBookingsForUser(currentUser.id);
    final now = DateTime.now();
    final activeBookings = allBookings.where((b) => b.endTime.isAfter(now)).toList();
    final pastBookings = allBookings.where((b) => b.endTime.isBefore(now)).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Οι Κρατήσεις μου'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ενεργές'),
              Tab(text: 'Ιστορικό'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _BookingsList(bookings: activeBookings, isActive: true),
            _BookingsList(bookings: pastBookings, isActive: false),
          ],
        ),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final List<Booking> bookings;
  final bool isActive;

  const _BookingsList({required this.bookings, required this.isActive});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isActive ? 'Δεν έχετε ενεργές κρατήσεις' : 'Δεν έχετε ιστορικό κρατήσεων',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _BookingCard(booking: booking, isActive: isActive);
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final bool isActive;
  final VoidCallback? onReviewSubmitted;

  const _BookingCard({required this.booking, required this.isActive, this.onReviewSubmitted});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/booking/${booking.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.spot.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isActive ? 'Ενεργή' : 'Ολοκληρώθηκε',
                      style: TextStyle(
                        color: isActive ? const Color(0xFF16A34A) : const Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Text(booking.spot.subtitle, style: const TextStyle(color: Color(0xFF6B7280))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Text(
                    '${dateFormat.format(booking.startTime)} - ${dateFormat.format(booking.endTime)}',
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock, size: 16, color: Color(0xFF2563EB)),
                          const SizedBox(width: 6),
                          Text(
                            'PIN: ${booking.pinCode}',
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!isActive)
                    OutlinedButton.icon(
                      onPressed: () => _showReviewDialog(context),
                      icon: const Icon(Icons.star_border, size: 18),
                      label: const Text('Αξιολόγηση'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFC107),
                        side: const BorderSide(color: Color(0xFFFFC107)),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    '€${booking.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    double rating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Αξιολόγηση: ${booking.spot.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final starValue = i + 1.0;
                  return IconButton(
                    onPressed: () => setDialogState(() => rating = starValue),
                    icon: Icon(
                      rating >= starValue ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Προσθέστε σχόλιο (προαιρετικό)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Ακύρωση'),
            ),
            ElevatedButton(
              onPressed: () {
                final currentUser = AppStateScope.of(context).currentUser;
                final review = Review(
                  userName: currentUser?.name ?? 'Χρήστης',
                  rating: rating,
                  comment: commentController.text.isEmpty ? 'Εξαιρετική εμπειρία!' : commentController.text,
                  date: DateTime.now(),
                );
                ParkingService().addReview(booking.spot.id, review);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Η αξιολόγησή σας καταχωρήθηκε!')),
                );
                onReviewSubmitted?.call();
              },
              child: const Text('Υποβολή'),
            ),
          ],
        ),
      ),
    );
  }
}
