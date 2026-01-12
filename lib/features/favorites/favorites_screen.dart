// lib/features/favorites/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/data/parking_service.dart';
import '../../core/state/app_state_scope.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AppStateScope.of(context).currentUser;
    
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Αγαπημένα')),
        body: const Center(child: Text('Πρέπει να συνδεθείτε')),
      );
    }

    final favoriteIds = currentUser.favoriteSpotIds;
    final allSpots = ParkingService().allSpots;
    final favoriteSpots = allSpots.where((s) => favoriteIds.contains(s.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Αγαπημένα')),
      body: favoriteSpots.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Δεν έχετε αγαπημένα',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Πατήστε την καρδιά σε ένα χώρο για να τον προσθέσετε',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteSpots.length,
              itemBuilder: (context, index) {
                final spot = favoriteSpots[index];
                return _FavoriteCard(spot: spot);
              },
            ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final GarageSpot spot;
  const _FavoriteCard({required this.spot});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/spot/${spot.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_parking, size: 40, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spot.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Color(0xFF6B7280)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            spot.subtitle,
                            style: const TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
                        const SizedBox(width: 4),
                        Text('${spot.rating.toStringAsFixed(1)}'),
                        const Spacer(),
                        Text(
                          '€${spot.pricePerHour.toStringAsFixed(0)}/ώρα',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  AppStateScope.of(context).toggleFavorite(spot.id);
                },
                icon: const Icon(Icons.favorite, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
