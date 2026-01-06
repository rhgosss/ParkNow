import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/utils/ui.dart';

class HostSpacesScreen extends StatefulWidget {
  const HostSpacesScreen({super.key});

  @override
  State<HostSpacesScreen> createState() => _HostSpacesScreenState();
}

class _HostSpacesScreenState extends State<HostSpacesScreen> {
  int tab = 0; // 0 all, 1 active, 2 inactive

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Οι Χώροι Μου'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => context.push('/host/new-space'),
              icon: const Icon(Icons.add),
              label: const Text('Νέος'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            Row(
              children: const [
                Expanded(child: _Kpi(value: '3', label: 'Χώροι')),
                Expanded(child: _Kpi(value: '25', label: 'Κρατήσεις\nμήνα')),
                Expanded(child: _Kpi(value: '€369', label: 'Έσοδα μήνα', valueColor: Color(0xFF16A34A))),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _pillTab('Όλοι (3)', tab == 0, () => setState(() => tab = 0)),
                const SizedBox(width: 8),
                _pillTab('Ενεργοί (2)', tab == 1, () => setState(() => tab = 1)),
                const SizedBox(width: 8),
                _pillTab('Ανενεργοί (1)', tab == 2, () => setState(() => tab = 2)),
              ],
            ),
            const SizedBox(height: 14),

            _spaceCard(
              onStats: () => context.push('/main'), // ή context.push('/host/stats') αν το κάνεις route
              onEdit: () => comingSoon(context, 'Επεξεργασία σύντομα'),
              onMenu: () => comingSoon(context),
            ),

            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/host/new-space'),
                icon: const Icon(Icons.add),
                label: const Text('Προσθήκη Νέου Χώρου'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _pillTab(String text, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.black87)),
      ),
    );
  }

  static Widget _spaceCard({
    required VoidCallback onStats,
    required VoidCallback onEdit,
    required VoidCallback onMenu,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1486006920555-c77dcf18193c?w=1600',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('Ενεργός', style: TextStyle(color: Colors.white)),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: InkWell(
                    onTap: onMenu,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.more_vert),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('€6/ημέρα', style: TextStyle(color: Colors.white)),
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
                const Text('Κολωνάκι Parking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF6B7280)),
                    SizedBox(width: 6),
                    Text('Σόλωνος 45, Αθήνα'),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.star, size: 18, color: Color(0xFFFFC107)),
                    SizedBox(width: 6),
                    Text('4.9 (87)'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF4FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Κρατήσεις', style: TextStyle(color: Color(0xFF2563EB))),
                            SizedBox(height: 6),
                            Text('12 αυτό τον\nμήνα', style: TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Έσοδα', style: TextStyle(color: Color(0xFF16A34A))),
                            SizedBox(height: 6),
                            Text('€156', style: TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onStats,
                        icon: const Icon(Icons.show_chart),
                        label: const Text('Stats'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Επεξεργασία'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  const _Kpi({required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: valueColor)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF6B7280))),
      ],
    );
  }
}
