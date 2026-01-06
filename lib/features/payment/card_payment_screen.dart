// lib/features/payment/card_payment_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CardPaymentScreen extends StatefulWidget {
  const CardPaymentScreen({super.key});

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final c1 = TextEditingController();
  final c2 = TextEditingController();
  final c3 = TextEditingController();

  @override
  void dispose() {
    c1.dispose();
    c2.dispose();
    c3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Κάρτα')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: c1,
            decoration: const InputDecoration(labelText: 'Αριθμός κάρτας'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: c2,
                  decoration: const InputDecoration(labelText: 'MM/YY'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: c3,
                  decoration: const InputDecoration(labelText: 'CVC'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () => context.go('/active-booking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: const Text('Πληρωμή €6.00', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
