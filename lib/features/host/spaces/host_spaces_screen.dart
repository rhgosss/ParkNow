import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/utils/ui.dart';
import '../../../core/data/parking_service.dart';
import '../../../core/state/app_state_scope.dart';

class HostSpacesScreen extends StatefulWidget {
  const HostSpacesScreen({super.key});

  @override
  State<HostSpacesScreen> createState() => _HostSpacesScreenState();
}

class _HostSpacesScreenState extends State<HostSpacesScreen> {
  int tab = 0; // 0 all, 1 active, 2 inactive

  @override
  Widget build(BuildContext context) {
    final user = AppStateScope.of(context).currentUser;
    final allSpots = ParkingService().allSpots;
    
    // Filter by owner name
    // For demo simplicity, we match exact string. 
    // In real app we'd use ID.
    final mySpots = allSpots.where((s) => s.ownerName == (user?.name ?? '')).toList();

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
        child: mySpots.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.garage_outlined, size: 64, color: Colors.grey),
                   const SizedBox(height: 16),
                   const Text('Δεν έχεις καταχωρήσει χώρους ακόμα.', style: TextStyle(fontSize: 16)),
                   const SizedBox(height: 24),
                   ElevatedButton(
                     onPressed: () => context.push('/host/new-space'),
                     child: const Text('Πρόσθεσε τον πρώτο σου χώρο'),
                   )
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: mySpots.length + 1, // +1 for header stats
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _Kpi(value: '${mySpots.length}', label: 'Χώροι')),
                          const Expanded(child: _Kpi(value: '0', label: 'Κρατήσεις\nμήνα')), // Mock
                          const Expanded(child: _Kpi(value: '€0', label: 'Έσοδα μήνα', valueColor: Color(0xFF16A34A))), // Mock
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _pillTab('Όλοι (${mySpots.length})', tab == 0, () => setState(() => tab = 0)),
                          const SizedBox(width: 8),
                          _pillTab('Ενεργοί', tab == 1, () => setState(() => tab = 1)),
                          const SizedBox(width: 8),
                          _pillTab('Ανενεργοί', tab == 2, () => setState(() => tab = 2)),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                  );
                }
                
                final spot = mySpots[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _spaceCard(
                    spot: spot,
                    onStats: () => context.push('/main'), 
                    onEdit: () => comingSoon(context, 'Επεξεργασία σύντομα'),
                    onMenu: () => comingSoon(context),
                  ),
                );
              },
            ),
      ),
      floatingActionButton: mySpots.isNotEmpty ? FloatingActionButton.extended(
        onPressed: () => context.push('/host/new-space'),
        icon: const Icon(Icons.add),
        label: const Text('Προσθήκη'),
      ) : null,
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
    required GarageSpot spot,
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
                Container(
                  height: 160,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                ),
                // If we implemented images in ParkingService, we'd use spot.image
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
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('€${spot.pricePerHour.toStringAsFixed(0)}/ώρα', style: const TextStyle(color: Colors.white)),
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
                Text(spot.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF6B7280)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(spot.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis)),
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
