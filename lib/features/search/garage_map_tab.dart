import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GarageMapTab extends StatefulWidget {
  const GarageMapTab({super.key});

  @override
  State<GarageMapTab> createState() => _GarageMapTabState();
}

class _GarageMapTabState extends State<GarageMapTab> {
  final ClusterManager _clusterManager = ClusterManager(
    clusterManagerId: const ClusterManagerId('garages'),
  );

  GoogleMapController? _mapController;
  GarageSpot? _selected;

  late final List<GarageSpot> _spots = _dummySpots();

  static const LatLng _athensCenter = LatLng(37.9838, 23.7275);

  @override
  Widget build(BuildContext context) {
    final markers = _spots.map((s) => _toMarker(s)).toSet();

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _athensCenter,
              zoom: 12,
            ),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            clusterManagers: {_clusterManager},
            markers: markers,
            onMapCreated: (c) => _mapController = c,
            onTap: (_) => setState(() => _selected = null),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: _TopSearchPill(
                      hint: 'Πού θέλεις να παρκάρεις;',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Search overlay: σύντομα')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  _RoundIconButton(
                    icon: Icons.tune,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Φίλτρα: σύντομα')),
                      );
                    },
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
                    onBook: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Κράτηση: σύντομα')),
                      );
                    },
                    onNavigate: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Οδηγίες: σύντομα')),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Marker _toMarker(GarageSpot s) {
    return Marker(
      markerId: MarkerId(s.id),
      position: s.pos,
      clusterManagerId: _clusterManager.clusterManagerId,
      onTap: () => setState(() => _selected = s),
      infoWindow: InfoWindow(
        title: s.title,
        snippet: '${s.pricePerHour.toStringAsFixed(0)}€/ώρα',
      ),
    );
  }

  List<GarageSpot> _dummySpots() {
    final rnd = Random(7);
    final areas = [
      'Κολωνάκι',
      'Σύνταγμα',
      'Πλάκα',
      'Παγκράτι',
      'Κυψέλη',
      'Αμπελόκηποι',
      'Νέος Κόσμος',
      'Γκάζι',
      'Μοναστηράκι',
      'Εξάρχεια',
    ];

    final out = <GarageSpot>[];
    for (var i = 0; i < 180; i++) {
      final lat = _athensCenter.latitude + (rnd.nextDouble() - 0.5) * 0.18;
      final lng = _athensCenter.longitude + (rnd.nextDouble() - 0.5) * 0.22;
      final area = areas[rnd.nextInt(areas.length)];
      final price = 5 + rnd.nextInt(6);
      out.add(
        GarageSpot(
          id: 'g$i',
          title: '$area Parking',
          subtitle: 'Αθήνα',
          pricePerHour: price.toDouble(),
          pos: LatLng(lat, lng),
        ),
      );
    }
    return out;
  }
}

class GarageSpot {
  final String id;
  final String title;
  final String subtitle;
  final double pricePerHour;
  final LatLng pos;

  GarageSpot({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.pricePerHour,
    required this.pos,
  });
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

  const _SpotCard({
    required this.spot,
    required this.onClose,
    required this.onBook,
    required this.onNavigate,
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                  child: Text(spot.subtitle, style: const TextStyle(color: Colors.black54)),
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
