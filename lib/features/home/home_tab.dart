import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/models.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    const spots = [
      ParkingSpot(
        title: 'Στεγασμένη Θέση Κέντρο',
        area: 'Αθήνα, Κολωνάκι',
        rating: 4.9,
        reviews: 127,
        pricePerHour: 8,
        imageUrl: 'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=1200',
      ),
      ParkingSpot(
        title: 'Υπόγειο Parking',
        area: 'Αθήνα, Σύνταγμα',
        rating: 4.8,
        reviews: 90,
        pricePerHour: 7,
        imageUrl: 'https://images.unsplash.com/photo-1501179691627-eeaa65ea017c?w=1200',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // top app bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                children: [
                  const Icon(Icons.local_parking, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('ParkNow', style: t.titleMedium?.copyWith(color: AppColors.primary)),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.person_outline),
                  ),
                ],
              ),
            ),

            // blue header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E63FF), Color(0xFF0F4FE6)],
                ),
              ),
              child: Column(
                children: [
                  Text('Βρες parking', style: t.titleLarge?.copyWith(color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('Χιλιάδες διαθέσιμοι χώροι', style: t.bodySmall?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.mutedText),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Που θέλεις να παρκάρεις;', style: t.bodyMedium?.copyWith(color: AppColors.mutedText)),
                        ),
                        InkWell(
                          onTap: () => context.push('/filters'),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.search, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Text('Προτεινόμενοι χώροι', style: t.titleMedium),
            ),

            ...spots.map(
              (s) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: InkWell(
                  onTap: () => context.push('/reviews'),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          child: Image.network(s.imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.title, style: t.titleMedium),
                                    const SizedBox(height: 4),
                                    Text(s.area, style: t.bodySmall),
                                    const SizedBox(height: 8),
                                    Text('${s.pricePerHour.toStringAsFixed(0)}€ /ώρα', style: t.titleMedium?.copyWith(color: AppColors.primary)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.star, color: Color(0xFFFFC107)),
                              const SizedBox(width: 4),
                              Text(s.rating.toStringAsFixed(1)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
