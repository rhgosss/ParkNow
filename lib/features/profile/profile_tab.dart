import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../screens/admin/admin_dashboard_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back)),
        title: const Text('Προφίλ'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Έξοδος')),
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
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.primary,
                    child: Text('ΓΠ', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                  const SizedBox(height: 10),
                  Text('Γιώργος Παπαδόπουλος', style: t.titleMedium),
                  const SizedBox(height: 4),
                  Text('george.p@email.com', style: t.bodySmall),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      ProfileStat('12', 'Κρατήσεις'),
                      SizedBox(width: 30),
                      ProfileStat('5', 'Αξιολογήσεις'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _menuTile(icon: Icons.person_outline, text: 'Επεξεργασία Προφίλ', onTap: () {}),
            const SizedBox(height: 10),
            _menuTile(icon: Icons.calendar_month_outlined, text: 'Οι Κρατήσεις μου', onTap: () {}),
            const SizedBox(height: 10),
            _menuTile(icon: Icons.favorite_border, text: 'Αγαπημένα', onTap: () {}),
            const SizedBox(height: 10),
            _menuTile(icon: Icons.payments_outlined, text: 'Πληρωμές', onTap: () {}),
            const SizedBox(height: 10),
            _menuTile(
              icon: Icons.admin_panel_settings_outlined,
              text: 'Admin Dashboard',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AdminDashboardScreen(),
                ),
              ),
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

class ProfileStat extends StatelessWidget {
  final String number;
  final String label;
  const ProfileStat(this.number, this.label, {super.key});

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
