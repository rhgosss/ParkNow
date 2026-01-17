// lib/features/shell/parker_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/parking_service.dart';
import '../../core/state/app_state_scope.dart';
import '../../shared/widgets/app_widgets.dart';
import '../search/garage_map_tab.dart';
import '../profile/profile_tab.dart';
import '../booking/my_bookings_screen.dart';

class ParkerShell extends StatefulWidget {
  const ParkerShell({super.key});

  @override
  State<ParkerShell> createState() => _ParkerShellState();
}

class _ParkerShellState extends State<ParkerShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const GarageMapTab(), // NEW: Full-screen map as home
      _NewSearchTab(onSwitchTab: (i) => setState(() => index = i)), // Old home content + Available Now
      const MyBookingsScreen(), // REAL BOOKINGS
      const ProfileTab(), // REAL PROFILE
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (v) => setState(() => index = v),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Χάρτης'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Αναζήτηση'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Κρατήσεις'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Προφίλ'),
        ],
      ),
    );
  }
}

// New Search Tab: Contains old home content + "Available Now" section
class _NewSearchTab extends StatelessWidget {
  final Function(int) onSwitchTab;
  const _NewSearchTab({required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final currentUser = AppStateScope.of(context).currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ParkNow'),
        // Messages button removed from Search tab
      ),
      body: SafeArea(
        child: StreamBuilder<List<GarageSpot>>(
          stream: ParkingService().spotsStream,
          initialData: ParkingService().allSpots,
          builder: (context, snapshot) {
            final allSpots = snapshot.data ?? [];
            
            // Filter: visible spots, exclude own spots if user is also host
            final visibleSpots = allSpots.where((s) {
              if (!s.isVisible) return false;
              // Conflict prevention: don't show own spots in user mode
              if (currentUser != null && s.ownerId == currentUser.id) return false;
              return true;
            }).toList();

            // Get spots that are available NOW (not currently booked)
            final availableNow = visibleSpots.where((s) => 
              !ParkingService().isSpotCurrentlyBooked(s.id)
            ).take(5).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                // Search bar
                InkWell(
                  onTap: () => context.push('/search'),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.location_on_outlined),
                        SizedBox(width: 10),
                        Expanded(child: Text('Πού θέλεις να παρκάρεις;')),
                        Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Quick action cards
                Row(
                  children: [
                    Expanded(
                      child: _quickCard(
                        icon: Icons.my_location,
                        title: 'Κοντά μου',
                        subtitle: 'Αυτόματη εύρεση',
                        onTap: () => onSwitchTab(0), // Switch to map tab
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _quickCard(
                        icon: Icons.tune,
                        title: 'Φίλτρα',
                        subtitle: 'Τιμή/Παροχές',
                        onTap: () => context.push('/filters'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                
                // AVAILABLE NOW Section
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Διαθέσιμα Τώρα', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Text('${availableNow.length} χώροι', style: const TextStyle(color: Color(0xFF6B7280))),
                  ],
                ),
                const SizedBox(height: 10),

                if (availableNow.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Δεν υπάρχουν διαθέσιμοι χώροι αυτή τη στιγμή', 
                        style: TextStyle(color: Color(0xFF6B7280))),
                    ),
                  )
                else
                  ...availableNow.map((spot) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _spotCard(
                      onTap: () => context.push('/spot/${spot.id}'),
                      spot: spot,
                      status: 'FREE',
                    ),
                  )),

                const SizedBox(height: 18),
                const Text('Προτεινόμενα', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),

                // Show first 2 spots from service
                ...visibleSpots.take(2).map((spot) {
                  final isBooked = ParkingService().isSpotCurrentlyBooked(spot.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _spotCard(
                      onTap: () => context.push('/spot/${spot.id}'),
                      spot: spot,
                      status: isBooked ? 'BOOKED' : 'FREE',
                    ),
                  );
                }),

                const SizedBox(height: 18),
                PrimaryButton(
                  text: 'Δες όλα στον χάρτη',
                  onPressed: () => onSwitchTab(0), // Switch to map tab
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static Widget _quickCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF2563EB)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _spotCard({
    required VoidCallback onTap,
    required GarageSpot spot,
    required String status,
  }) {
    final isBooked = status == 'BOOKED';
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: spot.imageUrl != null 
                    ? Image.network(spot.imageUrl!, width: 84, height: 64, fit: BoxFit.cover)
                    : Container(
                        width: 84, 
                        height: 64, 
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.local_parking, color: Colors.grey),
                      ),
                ),
                // Status badge
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isBooked ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(spot.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(spot.subtitle, style: const TextStyle(color: Color(0xFF6B7280))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
                      const SizedBox(width: 6),
                      Text(spot.rating.toStringAsFixed(1)),
                      const SizedBox(width: 10),
                      Text('€${spot.pricePerHour.toStringAsFixed(0)}/ώρα', 
                        style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w700)),
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
