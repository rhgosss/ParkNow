import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_widgets.dart';

class MapTab extends StatelessWidget {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context) {
    // “Map” mock με Stack + bottom sheet κάρτα
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // background (σαν χάρτης)
            Positioned.fill(
              child: Container(
                color: const Color(0xFFEFF4FF),
                child: const Center(child: Text('Map placeholder')),
              ),
            ),

            // top search pill
            Positioned(
              left: 16,
              right: 16,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.mutedText),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Κολωνάκι, Αθήνα\n18-20 Νοε'),
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.close)),
                  ],
                ),
              ),
            ),

            // chips row
            Positioned(
              left: 16,
              right: 16,
              top: 84,
              child: Row(
                children: [
                  ChipPill(text: 'Λίστα', onTap: () {}),
                  const SizedBox(width: 10),
                  const Expanded(child: SizedBox()),
                  InkWell(
                    onTap: () => context.push('/filters'),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
                      ),
                      child: const Icon(Icons.tune),
                    ),
                  )
                ],
              ),
            ),

            // bottom sheet card
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [BoxShadow(blurRadius: 18, color: Colors.black12)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                      child: Stack(
                        children: [
                          Image.network(
                            'https://images.unsplash.com/photo-1486006920555-c77dcf18193c?w=1200',
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text('€6/ημέρα', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            top: 8,
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.close, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text('Κολωνάκι Parking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: .12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.near_me_outlined, color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: const [
                              Icon(Icons.location_on_outlined, size: 16, color: AppColors.mutedText),
                              SizedBox(width: 6),
                              Text('Σόλωνος 45 • 0.5 km'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: const [
                              Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
                              SizedBox(width: 6),
                              Text('4.9 (127)'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: const [
                              ChipPill(text: 'Στεγασμένο'),
                              ChipPill(text: 'Φύλακας 24/7'),
                              ChipPill(text: 'Κάμερες'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          PrimaryButton(
                          text: 'Κράτηση',
                          onPressed: () {},
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
