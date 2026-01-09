// lib/features/search/results_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResultsListScreen extends StatelessWidget {
  final bool showBack;
  const ResultsListScreen({super.key, required this.showBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: showBack ? const BackButton() : null,
        title: const Text('Διαθέσιμα Parking'),
        actions: [
          IconButton(
            onPressed: () => context.push('/search/map'),
            icon: const Icon(Icons.map_outlined),
          ),
          IconButton(
            onPressed: () => context.push('/filters'),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            context,
            image: 'https://images.unsplash.com/photo-1486006920555-c77dcf18193c?w=1400',
            title: 'Κολωνάκι Parking',
            area: 'Σόλωνος 45, Αθήνα',
            price: '€6/ημέρα',
            rating: '4.9 (87)',
          ),
          const SizedBox(height: 12),
          _card(
            context,
            image: 'https://images.unsplash.com/photo-1501179691627-eeaa65ea017c?w=1400',
            title: 'Σύνταγμα Plaza',
            area: 'Κέντρο Αθήνας',
            price: '€8/ημέρα',
            rating: '4.8 (54)',
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String image,
    required String title,
    required String area,
    required String price,
    required String rating,
  }) {
    return InkWell(
      onTap: () => context.push('/spot'),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(image, height: 170, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF6B7280)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(area, style: const TextStyle(color: Color(0xFF6B7280)))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Color(0xFFFFC107)),
                      const SizedBox(width: 6),
                      Text(rating),
                      const Spacer(),
                      Text(price, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
