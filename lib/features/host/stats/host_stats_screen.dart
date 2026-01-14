import 'package:flutter/material.dart';
import '../../../shared/utils/ui.dart';
import '../../../core/data/parking_service.dart';
import '../../../core/state/app_state_scope.dart';

class HostStatsScreen extends StatelessWidget {
  const HostStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AppStateScope.of(context).currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Στατιστικά')),
        body: const Center(child: Text('Πρέπει να συνδεθείτε')),
      );
    }

    // Calculate real stats
    final allBookings = ParkingService().getBookingsForOwner(currentUser.id);
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    
    final monthlyBookings = allBookings.where((b) => 
      b.startTime.isAfter(monthStart) && b.startTime.isBefore(now)
    ).toList();
    
    final monthlyIncome = monthlyBookings.fold<double>(
      0.0, 
      (sum, booking) => sum + booking.totalPrice
    );

    final uniqueCustomers = monthlyBookings.map((b) => b.userId).toSet().length;
    final spotsCount = ParkingService().getSpotsForOwner(currentUser.id).length;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Στατιστικά'),
        actions: [
          IconButton(
            onPressed: () => comingSoon(context, 'Λήψη αναφοράς σύντομα'),
            icon: const Icon(Icons.download),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            Row(
              children: const [
                _Seg(text: 'Εβδομάδα', active: false),
                SizedBox(width: 8),
                _Seg(text: 'Μήνας', active: true),
                SizedBox(width: 8),
                _Seg(text: 'Έτος', active: false),
              ],
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF22C55E)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.attach_money, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Έσοδα Μήνα', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '€${monthlyIncome.toStringAsFixed(2)}', 
                    style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Από ${monthlyBookings.length} κρατήσεις',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _Mini(
                    title: 'Κρατήσεις', 
                    value: monthlyBookings.length.toString(), 
                    sub: 'Αυτόν τον μήνα',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Mini(
                    title: 'Πελάτες', 
                    value: uniqueCustomers.toString(), 
                    sub: 'Μοναδικοί',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _Mini(
                    title: 'Χώροι', 
                    value: spotsCount.toString(), 
                    sub: 'Ενεργοί',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Mini(
                    title: 'Μέσος Όρος', 
                    value: monthlyBookings.isEmpty 
                      ? '€0' 
                      : '€${(monthlyIncome / monthlyBookings.length).toStringAsFixed(0)}', 
                    sub: 'Ανά κράτηση',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Container(
              height: 180,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Center(child: Text('Chart placeholder')),
            ),
          ],
        ),
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  final String text;
  final bool active;
  const _Seg({required this.text, required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.black87)),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(14)),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}

class _Mini extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  const _Mini({required this.title, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(sub, style: const TextStyle(color: Color(0xFF16A34A))),
        ],
      ),
    );
  }
}
