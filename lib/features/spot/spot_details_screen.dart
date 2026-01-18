// lib/features/spot/spot_details_screen.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/data/parking_service.dart';
import '../../../core/data/chat_service.dart';
import '../../../core/state/app_state_scope.dart';
import '../../../shared/widgets/app_widgets.dart';

class SpotDetailsScreen extends StatefulWidget {
  final String spotId;
  const SpotDetailsScreen({super.key, required this.spotId});

  @override
  State<SpotDetailsScreen> createState() => _SpotDetailsScreenState();
}

class _SpotDetailsScreenState extends State<SpotDetailsScreen> {
  bool _isDaily = false;
  GarageSpot? _spot;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _spot = ParkingService().getSpot(widget.spotId);
    if (_spot != null) {
      _markers = {
        Marker(markerId: MarkerId(_spot!.id), position: _spot!.pos),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_spot == null) {
      return const Scaffold(body: Center(child: Text('Spot not found')));
    }
    final s = _spot!;
    final price = _isDaily ? s.pricePerDay : s.pricePerHour;
    final priceLabel = _isDaily ? 'ημέρα' : 'ώρα';
    final isFavorite = AppStateScope.of(context).isFavorite(s.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.title),
        actions: [
          IconButton(
            onPressed: () {
              AppStateScope.of(context).toggleFavorite(s.id);
              setState(() {}); // Refresh to update icon
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Map Preview
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(target: s.pos, zoom: 15),
                    markers: _markers,
                    // Interactive Map enabled per user request
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                    myLocationButtonEnabled: false,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: FloatingActionButton.small(
                    onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Άνοιγμα σε πλήρη οθόνη... (Demo)')),
                         );
                    },
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.fullscreen, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Header Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(s.area, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('€${price.toStringAsFixed(1)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                  Text('/$priceLabel', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pricing Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(child: _toggleBtn('Ανά Ώρα', !_isDaily, () => setState(() => _isDaily = false))),
                Expanded(child: _toggleBtn('Ανά Ημέρα (Save)', _isDaily, () => setState(() => _isDaily = true))),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Owner Info with Host Avatar (TASK 5)
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE5E7EB),
                backgroundImage: s.ownerPhotoUrl != null && s.ownerPhotoUrl!.isNotEmpty
                    ? (s.ownerPhotoUrl!.startsWith('data:')
                        ? MemoryImage(_decodeBase64(s.ownerPhotoUrl!))
                        : NetworkImage(s.ownerPhotoUrl!) as ImageProvider)
                    : null,
                child: s.ownerPhotoUrl == null || s.ownerPhotoUrl!.isEmpty
                    ? Text(
                        s.ownerName.isNotEmpty ? s.ownerName[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ιδιοκτήτης', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(s.ownerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  ],
                ),
              ),
              // Contact Host button - HIDDEN IF USER IS OWNER
              if (s.ownerId != AppStateScope.of(context).currentUser?.id)
                OutlinedButton.icon(
                  onPressed: () => _contactHost(context, s),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Επικοινωνία'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF2563EB)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
            ],
          ),
          const Divider(height: 32),

          // Facilities
          const Text('Παροχές', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: s.features.map((f) => _Tag(f)).toList(),
          ),
          const Divider(height: 32),

          // Reviews
          Row(
            children: [
              const Text('Κριτικές', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Colors.amber, size: 20),
              Text(' ${s.rating.toStringAsFixed(1)} (${s.reviewsCount})', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...s.reviews.map((r) => _ReviewItem(r)),

          const SizedBox(height: 30),
          SizedBox(
            height: 54,
            child: PrimaryButton(
              text: 'Επιλογή ημερομηνίας',
              onPressed: () {
                 final price = _isDaily ? s.pricePerDay : s.pricePerHour;
                 final type = _isDaily ? 'day' : 'hour';
                 // Use slot-booking for hourly, date picker for daily
                 final path = _isDaily ? '/date' : '/slot-booking';
                 context.push(Uri(path: path, queryParameters: {
                   'spotId': s.id,
                   'price': price.toString(),
                   'type': type,
                 }).toString());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
        ),
        alignment: Alignment.center,
        child: Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: active ? Colors.black : Colors.grey)),
      ),
    );
  }

  Future<void> _contactHost(BuildContext context, GarageSpot spot) async {
    final currentUser = AppStateScope.of(context).currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Πρέπει να συνδεθείτε για να στείλετε μήνυμα')),
      );
      return;
    }

    // Can't message your own spot
    if (spot.ownerId == currentUser.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Δεν μπορείτε να στείλετε μήνυμα στον εαυτό σας')),
      );
      return;
    }

    // Get or create chat room for this spot using new chat_rooms structure
    final chatRoom = await ChatService().getOrCreateChatRoom(
      spotId: spot.id,
      spotTitle: spot.title,
      hostId: spot.ownerId ?? 'unknown',
      hostName: spot.ownerName,
      renterId: currentUser.id,
      renterName: currentUser.name,
    );

    if (context.mounted) {
      context.push(Uri(path: '/chat', queryParameters: {
        'id': chatRoom.id,
        'name': spot.ownerName,
      }).toString());
    }
  }

  Uint8List _decodeBase64(String dataUrl) {
    final base64String = dataUrl.split(',').last;
    return base64Decode(base64String);
  }
}

class _ReviewItem extends StatelessWidget {
  final Review r;
  const _ReviewItem(this.r);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(r.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text(r.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                   const Icon(Icons.star, size: 14, color: Colors.amber),
                ],
              )
            ],
          ),
          const SizedBox(height: 4),
          Text(r.comment, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String t;
  const _Tag(this.t);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
      child: Text(t),
    );
  }
}
