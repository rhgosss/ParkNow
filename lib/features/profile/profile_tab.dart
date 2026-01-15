import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/state/app_state_scope.dart';
import '../../core/data/parking_service.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final currentUser = AppStateScope.of(context).currentUser;
    
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Προφίλ')),
        body: const Center(child: Text('Πρέπει να συνδεθείτε')),
      );
    }

    final bookingCount = ParkingService().getBookingsForUser(currentUser.id).length;
    final initials = currentUser.name.split(' ').map((n) => n[0]).take(2).join().toUpperCase();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/main'), 
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Προφίλ'),
        actions: [
          TextButton(
            onPressed: () {
              AppStateScope.of(context).logout();
              context.go('/login');
            }, 
            child: const Text('Έξοδος'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.primary,
                    child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                  const SizedBox(height: 10),
                  Text(currentUser.name, style: t.titleMedium),
                  const SizedBox(height: 4),
                  Text(currentUser.email, style: t.bodySmall),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatItem(bookingCount.toString(), 'Κρατήσεις'),
                      const SizedBox(width: 30),
                      const _StatItem('5', 'Αξιολογήσεις'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _menuTile(
              icon: Icons.person_outline, 
              text: 'Επεξεργασία Προφίλ', 
              onTap: () => context.push('/edit-profile'),
            ),
            const SizedBox(height: 10),
            _menuTile(
              icon: Icons.calendar_month_outlined, 
              text: 'Οι Κρατήσεις μου', 
              onTap: () => context.push('/my-bookings'),
            ),
            const SizedBox(height: 10),
            _menuTile(
              icon: Icons.favorite_border, 
              text: 'Αγαπημένα', 
              onTap: () => context.push('/favorites'),
            ),
            const SizedBox(height: 10),
            _menuTile(
              icon: Icons.payments_outlined, 
              text: 'Πληρωμές', 
              onTap: () => context.push('/payments'),
            ),
            const SizedBox(height: 10),
            _menuTile(
              icon: Icons.admin_panel_settings_outlined,
              text: 'Admin Dashboard',
              onTap: () => context.push('/admin'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _menuTile({required IconData icon, required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.mutedText),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
            const Icon(Icons.chevron_right, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;
  const _StatItem(this.number, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(number, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.mutedText)),
      ],
    );
  }
}
