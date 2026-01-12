// lib/features/payment/payment_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/data/parking_service.dart';
import '../../../core/state/app_state_scope.dart';
import '../../../shared/widgets/app_widgets.dart';

class PaymentScreen extends StatelessWidget {
  final Map<String, String> params;
  const PaymentScreen({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    final total = params['total'] ?? '0';

    return Scaffold(
      appBar: AppBar(title: const Text('Πληρωμή')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Σύνολο', style: TextStyle(color: Color(0xFF2563EB))),
                  const SizedBox(height: 6),
                  Text('€$total', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 54,
              child: PrimaryButton(
                text: 'Πληρωμή με κάρτα',
                onPressed: () {
                   _simulateBooking(context);
                   context.push('/payment-card');
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 54,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _simulateBooking(context);
                  context.go('/active-booking');
                },
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Πληρωμή στο κατάστημα (demo)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateBooking(BuildContext context) {
    if (params['spotId'] == null) return;
    
    final spot = ParkingService().getSpot(params['spotId']!);
    if (spot == null) return;

    // Get current user
    final currentUser = AppStateScope.of(context).currentUser;
    if (currentUser == null) return;

    // Use passed params or defaults
    final price = double.parse(params['total'] ?? '0');
    final startTime = DateTime.parse(params['date'] ?? DateTime.now().toIso8601String());
    final type = params['type'] ?? 'hour';
    final duration = int.parse(params['duration'] ?? '2');
    
    final endTime = type == 'day' 
        ? startTime.add(Duration(days: duration)) 
        : startTime.add(Duration(hours: duration));
    
    // Generate unique 4-digit PIN
    final pinCode = (1000 + Random().nextInt(9000)).toString();
    
    final booking = Booking(
      id: 'b_${DateTime.now().millisecondsSinceEpoch}', 
      spot: spot, 
      startTime: startTime, 
      endTime: endTime,
      totalPrice: price,
      userId: currentUser.id,
      pinCode: pinCode,
    );

    ParkingService().addBooking(booking);
  }
}
