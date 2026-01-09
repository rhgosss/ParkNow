import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/spots_db.dart';
import '../shared/models/models.dart';

class ParkingSpotsDbViewScreen extends StatefulWidget {
  const ParkingSpotsDbViewScreen({super.key});

  @override
  State<ParkingSpotsDbViewScreen> createState() => _ParkingSpotsDbViewScreenState();
}

class _ParkingSpotsDbViewScreenState extends State<ParkingSpotsDbViewScreen> {
  final _db = SpotsDb();
  bool _loading = true;
  String? _error;
  List<ParkingSpot> _spots = [];
  List<ParkingSpot> _filtered = [];

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filtered = _spots;
      } else {
        _filtered = _spots.where((s) {
          return s.title.toLowerCase().contains(q) || s.area.toLowerCase().contains(q) || s.id.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final spots = await _db.getAllSpots();
      setState(() {
        _spots = spots;
        _filtered = spots;
        if (_searchCtrl.text.isNotEmpty) _onSearchChanged();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteSpot(String id) async {
    try {
      await _db.deleteSpot(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Spot deleted successfully')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting spot: $e')),
      );
    }
  }

  void _confirmDelete(ParkingSpot spot) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete spot'),
        content: Text('Delete "${spot.title}" (${spot.area})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteSpot(spot.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Parking Spots'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by title, area or id...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _filtered.isEmpty
                        ? const Center(child: Text('No spots found.'))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final spot = _filtered[index];
                              return _SpotCard(
                                spot: spot,
                                onDelete: () => _confirmDelete(spot),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _SpotCard extends StatelessWidget {
  final ParkingSpot spot;
  final VoidCallback onDelete;

  const _SpotCard({required this.spot, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withValues(alpha: 0.10),
          child: const Icon(Icons.local_parking_rounded, color: AppColors.primary),
        ),
        title: Text(spot.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(spot.area, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(text: '€${spot.pricePerHour.toStringAsFixed(2)}/h'),
                _Chip(text: '⭐ ${spot.rating.toStringAsFixed(1)} (${spot.reviews})'),
                _Chip(text: 'ID: ${spot.id}'),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          tooltip: 'Delete',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
    );
  }
}
