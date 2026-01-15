import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/data/parking_service.dart';
import '../../../core/state/app_state_scope.dart';

class GarageMapTab extends StatefulWidget {
  const GarageMapTab({super.key});

  @override
  State<GarageMapTab> createState() => _GarageMapTabState();
}

class _GarageMapTabState extends State<GarageMapTab> {
  GarageSpot? _selected;
  DateTime _filterDate = DateTime.now(); // Default now

  static const LatLng _athensCenter = LatLng(37.9838, 23.7275);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GarageSpot>>(
      stream: ParkingService().spotsStream,
      initialData: ParkingService().allSpots,
      builder: (context, snapshot) {
        final spots = snapshot.data ?? [];
        final markers = spots.map((s) => _toMarker(s)).toSet();

        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _athensCenter,
                  zoom: 14,
                ),
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: markers,
                onMapCreated: (c) {},
                onTap: (_) => setState(() => _selected = null),
              ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _TopSearchPill(
                          hint: 'Πού θέλεις να παρκάρεις;',
                          onTap: () => context.push('/search'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _RoundIconButton(
                        icon: Icons.tune,
                        onTap: () => context.push('/filters'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Διαθεσιμότητα:',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () =>
                              setState(() => _filterDate = DateTime.now()),
                          child: Text(
                            'Τώρα',
                            style: TextStyle(
                              color: _isNow(_filterDate)
                                  ? const Color(0xFF2563EB)
                                  : Colors.black54,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('|', style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => setState(() => _filterDate =
                              DateTime.now().add(const Duration(hours: 12))),
                          child: Text(
                            'Αργότερα',
                            style: TextStyle(
                              color: !_isNow(_filterDate)
                                  ? const Color(0xFF2563EB)
                                  : Colors.black54,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('Διαθέσιμο',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 16),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('Κατειλημμένο',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selected != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _SpotCard(
                    spot: _selected!,
                    onClose: () => setState(() => _selected = null),
                    onBook: () => context.push('/spot/${_selected!.id}'),
                    onToggleFavorite: () {
                      AppStateScope.of(context).toggleFavorite(_selected!.id);
                      setState(() {});
                    },
                    isFavorite: AppStateScope.of(context).isFavorite(_selected!.id),
                    onNavigate: () async {
                      final uri = Uri.parse(
                        'https://www.google.com/maps/search/?api=1&query=${_selected!.pos.latitude},${_selected!.pos.longitude}',
                      );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Δεν βρέθηκε εφαρμογή χαρτών.')),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isNow(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year &&
        d.month == now.month &&
        d.day == now.day &&
        (d.hour - now.hour).abs() < 1;
  }

  // ΟΛΑ ΠΡΑΣΙΝΑ PINS
  Marker _toMarker(GarageSpot s) {
    return Marker(
      markerId: MarkerId(s.id),
      position: s.pos,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      onTap: () => setState(() => _selected = s),
    );
  }
}

class _TopSearchPill extends StatelessWidget {
  final String hint;
  final VoidCallback onTap;

  const _TopSearchPill({required this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(999),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hint,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.search, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shape: const CircleBorder(),
      color: Colors.white,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}

class _SpotCard extends StatelessWidget {
  final GarageSpot spot;
  final VoidCallback onClose;
  final VoidCallback onBook;
  final VoidCallback onNavigate;
  final VoidCallback onToggleFavorite;
  final bool isFavorite;

  const _SpotCard({
    required this.spot,
    required this.onClose,
    required this.onBook,
    required this.onNavigate,
    required this.onToggleFavorite,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    spot.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(spot.subtitle,
                      style: const TextStyle(color: Colors.black54)),
                ),
                Text(
                  '${spot.pricePerHour.toStringAsFixed(0)}€/ώρα',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onNavigate,
                    icon: const Icon(Icons.near_me_outlined),
                    label: const Text('Οδηγίες'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onBook,
                    child: const Text('Κράτηση'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
