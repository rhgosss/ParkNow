// lib/features/shell/parker_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/parking_service.dart';
import '../../shared/widgets/app_widgets.dart';
import '../search/results_list_screen.dart';
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
      _ParkerHomeTab(onSwitchTab: (i) => setState(() => index = i)),
      const ResultsListScreen(showBack: false),
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Αρχική'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Αναζήτηση'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Κρατήσεις'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Προφίλ'),
        ],
      ),
    );
  }
}

class _ParkerHomeTab extends StatelessWidget {
  final Function(int) onSwitchTab;
  const _ParkerHomeTab({required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ParkNow'),
        actions: [
          IconButton(
            onPressed: () => context.push('/messages'),
            icon: const Icon(Icons.chat_bubble_outline),
          ),
          IconButton(
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
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

            Row(
              children: [
                Expanded(
                  child: _quickCard(
                    icon: Icons.my_location,
                    title: 'Κοντά μου',
                    subtitle: 'Αυτόματη εύρεση',
                    onTap: () => onSwitchTab(1), // Switch to search tab
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
            const Text('Προτεινόμενα', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),

            // Get first 2 spots from service
            ...ParkingService().allSpots.take(2).map((spot) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _spotCard(
                onTap: () => context.push('/spot/${spot.id}'),
                image: 'https://images.unsplash.com/photo-1501179691627-eeaa65ea017c?w=1200',
                title: spot.title,
                area: spot.subtitle,
                price: '€${spot.pricePerHour.toStringAsFixed(0)}/ώρα',
                rating: spot.rating.toStringAsFixed(1),
              ),
            )),

            const SizedBox(height: 18),
            PrimaryButton(
              text: 'Δες όλα τα διαθέσιμα',
              onPressed: () => onSwitchTab(1), // Switch to search tab
            ),
          ],
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
    required String image,
    required String title,
    required String area,
    required String price,
    required String rating,
  }) {
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
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(image, width: 84, height: 64, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(area, style: const TextStyle(color: Color(0xFF6B7280))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
                      const SizedBox(width: 6),
                      Text(rating),
                      const SizedBox(width: 10),
                      Text(price, style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w700)),
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
