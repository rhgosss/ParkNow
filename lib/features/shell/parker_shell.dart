// lib/features/shell/parker_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/app_widgets.dart';
import '../search/results_list_screen.dart';

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
      const _ParkerHomeTab(),
      const ResultsListScreen(showBack: false), // εδώ είναι οι λίστες με photos
      const _ParkerBookingsTab(),
      const _ParkerProfileTab(),
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
  const _ParkerHomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ParkNow'),
        actions: [
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
                    onTap: () => context.go('/results'),
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

            _spotCard(
              onTap: () => context.push('/spot'),
              image:
                  'https://images.unsplash.com/photo-1501179691627-eeaa65ea017c?w=1200',
              title: 'Στεγασμένη Θέση Κέντρο',
              area: 'Κολωνάκι, Αθήνα',
              price: '8€/ώρα',
              rating: '4.9',
            ),
            const SizedBox(height: 12),
            _spotCard(
              onTap: () => context.push('/spot'),
              image:
                  'https://images.unsplash.com/photo-1486006920555-c77dcf18193c?w=1200',
              title: 'Υπόγειο Parking',
              area: 'Σύνταγμα, Αθήνα',
              price: '10€/ώρα',
              rating: '4.8',
            ),

            const SizedBox(height: 18),
            PrimaryButton(
              text: 'Δες όλα τα διαθέσιμα',
              onPressed: () => context.go('/results'),
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

class _ParkerBookingsTab extends StatelessWidget {
  const _ParkerBookingsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Κρατήσεις')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF16A34A)),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('Έχεις ενεργή κράτηση')),
                  ElevatedButton(
                    onPressed: () => context.push('/active-booking'),
                    child: const Text('Άνοιγμα'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('Ιστορικό', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _historyRow('Κολωνάκι Parking', '18-20 Νοε', '€13.00'),
            _historyRow('Σύνταγμα Plaza', '03 Νοε', '€6.00'),
          ],
        ),
      ),
    );
  }

  static Widget _historyRow(String title, String date, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(color: Color(0xFF6B7280))),
            ]),
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2563EB))),
        ],
      ),
    );
  }
}

class _ParkerProfileTab extends StatelessWidget {
  const _ParkerProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Προφίλ')),
      body: const Center(child: Text('Profile UI (το κρατάμε όπως το έχεις ήδη)')),
    );
  }
}
