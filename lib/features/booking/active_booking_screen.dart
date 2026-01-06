// lib/features/booking/active_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActiveBookingScreen extends StatelessWidget {
  const ActiveBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PIN Πρόσβασης', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w800)),
                  SizedBox(height: 8),
                  Text('4821', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                  SizedBox(height: 6),
                  Text('Δείξ’ το στον host ή χρησιμοποίησέ το στο keypad.'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 54,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/chat'),
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
