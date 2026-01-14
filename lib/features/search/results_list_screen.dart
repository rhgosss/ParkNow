// lib/features/search/results_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/parking_service.dart';
import '../../../core/state/app_state_scope.dart';

class ResultsListScreen extends StatefulWidget {
  final bool showBack;
  final String? query; // Passed via query params

  const ResultsListScreen({super.key, required this.showBack, this.query});

  @override
  State<ResultsListScreen> createState() => _ResultsListScreenState();
}

class _ResultsListScreenState extends State<ResultsListScreen> {
  @override
  Widget build(BuildContext context) {
    // Get results from service
    final results = ParkingService().search(widget.query ?? '');

    return Scaffold(
      appBar: AppBar(
        leading: widget.showBack ? const BackButton() : null,
        title: Text(widget.query != null && widget.query!.isNotEmpty ? 'Αποτελέσματα: "${widget.query}"' : 'Διαθέσιμα Parking'),
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
      body: results.isEmpty 
        ? const Center(child: Text('Δεν βρέθηκαν αποτελέσματα.')) 
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final spot = results[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _card(context, spot),
            );
          },
        ),
    );
  }

  Widget _card(BuildContext context, GarageSpot spot) {
    final isFavorite = AppStateScope.of(context).isFavorite(spot.id);
    
    return InkWell(
      onTap: () => context.push('/spot/${spot.id}'),
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Container(
                    height: 170,
                    width: double.infinity,
                    color: Colors.grey[300], // Placeholder color
                    child: const Icon(Icons.local_parking, size: 60, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      AppStateScope.of(context).toggleFavorite(spot.id);
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(spot.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF6B7280)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(spot.subtitle, style: const TextStyle(color: Color(0xFF6B7280)))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Color(0xFFFFC107)),
                      const SizedBox(width: 6),
                      Text('${spot.rating.toStringAsFixed(1)} (${spot.reviewsCount})'),
                      const Spacer(),
                      Text('€${spot.pricePerHour.toStringAsFixed(0)}/ώρα', style: const TextStyle(fontWeight: FontWeight.w800)),
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
