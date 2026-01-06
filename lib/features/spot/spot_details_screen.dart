// lib/features/spot/spot_details_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SpotDetailsScreen extends StatelessWidget {
  const SpotDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Λεπτομέρειες')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              'https://images.unsplash.com/photo-1486006920555-c77dcf18193c?w=1400',
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          const Text('Κολωνάκι Parking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF6B7280)),
              SizedBox(width: 6),
              Text('Σόλωνος 45, Αθήνα', style: TextStyle(color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Παροχές', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _Tag('Στεγασμένο'),
              _Tag('Κάμερες'),
              _Tag('Φωτισμός'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () => context.push('/date'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: const Text('Επιλογή ημερομηνίας', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String t;
  const _Tag(this.t);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
      child: Text(t),
    );
  }
}
