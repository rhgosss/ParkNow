import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/data/parking_service.dart';
import '../../../core/state/app_state_scope.dart';

class AccessMethodScreen extends StatefulWidget {
  final Map<String, String> params;
  const AccessMethodScreen({super.key, this.params = const {}});

  @override
  State<AccessMethodScreen> createState() => _AccessMethodScreenState();
}

class _AccessMethodScreenState extends State<AccessMethodScreen> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Τρόπος Πρόσβασης'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Progress(step: 2),
              const SizedBox(height: 18),
              const Text('Πώς θα έχει πρόσβαση ο πελάτης;', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                'Επίλεξε τον τρόπο με τον οποίο οι\nπελάτες θα εισέρχονται στο χώρο\nστάθμευσης',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 14),

              _option(
                i: 0,
                selected: selected,
                icon: Icons.key_outlined,
                title: 'Κωδικός\nΠρόσβασης',
                badge: 'Δημοφιλές',
                subtitle: 'Ψηφιακό κλειδί ή PIN',
                onTap: () => setState(() => selected = 0),
              ),
              const SizedBox(height: 12),
              _option(
                i: 1,
                selected: selected,
                icon: Icons.lock_outline,
                title: 'Φυσικό Κλειδί/\nΛουκέτο',
                subtitle: 'Παράδοση κλειδιών',
                onTap: () => setState(() => selected = 1),
              ),
              const SizedBox(height: 12),
              _option(
                i: 2,
                selected: selected,
                icon: Icons.credit_card_outlined,
                title: 'Κάρτα Πρόσβασης',
                subtitle: 'RFID ή μαγνητική κάρτα',
                onTap: () => setState(() => selected = 2),
              ),
              const SizedBox(height: 12),
              _option(
                i: 3,
                selected: selected,
                icon: Icons.person_outline,
                title: 'Παρουσία Host',
                subtitle: 'Θα είμαι εκεί να ανοίξω',
                onTap: () => setState(() => selected = 3),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      child: const Text('Πίσω'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                         final title = widget.params['title'] ?? 'Χωρίς Τίτλο';
                         final addr = widget.params['addr'] ?? 'Αθήνα';
                         final price = double.tryParse(widget.params['price'] ?? '5') ?? 5.0;
                         final currentUser = AppStateScope.of(context).currentUser;
                         final owner = currentUser?.name ?? 'Me';
                         
                         final lat = double.tryParse(widget.params['lat'] ?? '') ?? 37.9838;
                         final lng = double.tryParse(widget.params['lng'] ?? '') ?? 23.7275;
                         
                         // Create Spot with unique ID
                         final spot = GarageSpot(
                           id: 'spot_${DateTime.now().millisecondsSinceEpoch}',
                           title: title,
                           subtitle: addr,
                           area: 'Κέντρο',
                           pricePerHour: price,
                           pricePerDay: price * 10,
                           pos: LatLng(lat, lng),
                           rating: 5.0,
                           reviewsCount: 0,
                           features: ['Covered', '24/7'],
                           ownerName: owner,
                           reviews: [],
                           ownerId: currentUser?.id,
                         );
                         
                         // Save to Firestore
                         await ParkingService().addSpot(spot);
                         
                         // Navigate to Success
                         if (context.mounted) {
                           context.push(Uri(path: '/host/success', queryParameters: {
                             'title': title,
                             'price': widget.params['price'] ?? '5',
                             'addr': addr,
                           }).toString());
                         }
                      },
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      child: const Text('Δημοσίευση'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option({
    required int i,
    required int selected,
    required IconData icon,
    required String title,
    String? badge,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final active = i == selected;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEFF4FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: active ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB), width: active ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: active ? Colors.white : const Color(0xFF6B7280)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(badge, style: const TextStyle(color: Color(0xFF16A34A))),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF2563EB))),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF2563EB) : Colors.transparent,
                border: Border.all(color: active ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB)),
                shape: BoxShape.circle,
              ),
              child: active ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  final int step;
  const _Progress({required this.step});

  @override
  Widget build(BuildContext context) {
    Widget bar(bool active) => Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );

    return Row(
      children: [
        bar(step >= 1),
        const SizedBox(width: 8),
        bar(step >= 2),
        const SizedBox(width: 8),
        bar(step >= 3),
      ],
    );
  }
}
