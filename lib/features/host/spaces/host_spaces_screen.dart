import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/utils/ui.dart';
import '../../../core/theme/app_colors.dart';
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
  @override
  Widget build(BuildContext context) {
    final user = AppStateScope.of(context).currentUser;

    return StreamBuilder<List<GarageSpot>>(
      stream: ParkingService().spotsStream,
      initialData: ParkingService().allSpots,
      builder: (context, snapshot) {
        final allSpots = snapshot.data ?? [];
        // Filter by owner ID (preferred) or Name
        final mySpots = allSpots.where((s) => s.ownerId == user?.id || s.ownerName == (user?.name ?? '')).toList();

        // Calculate Stats from real data
        final activeSpotsCount = mySpots.length;
        // Mock revenue calculation based on spots price (real app would query bookings)
        final projectedRevenue = mySpots.fold<double>(0, (sum, spot) => sum + (spot.pricePerHour * 10)); 

        return Scaffold(
          backgroundColor: const Color(0xFFF7F7F7), // Airbnb light grey bg
          appBar: AppBar(
            automaticallyImplyLeading: false, // Remove back button
            title: const Text('My Hosting', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.white,
            // REMOVED duplicate 'Add' button from actions
          ),
          body: SafeArea(
            child: mySpots.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(Icons.house_siding_rounded, size: 64, color: Colors.grey.shade300),
                       const SizedBox(height: 16),
                       const Text('No spaces listed yet.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                       const SizedBox(height: 8),
                       const Text('Start earning by listing your parking spot.', style: TextStyle(color: Colors.grey)),
                       const SizedBox(height: 24),
                       ElevatedButton(
                         onPressed: () => context.push('/host/new-space'),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: AppColors.primary,
                           foregroundColor: Colors.white,
                           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                         ),
                         child: const Text('List your space'),
                       )
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  itemCount: mySpots.length + 1, 
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(child: _Kpi(value: '$activeSpotsCount', label: 'Active\nSpaces')),
                                Container(width: 1, height: 40, color: Colors.grey.shade200),
                                const Expanded(child: _Kpi(value: '100%', label: 'Response\nRate')), // Mock
                                Container(width: 1, height: 40, color: Colors.grey.shade200),
                                Expanded(child: _Kpi(value: '€${projectedRevenue.toStringAsFixed(0)}', label: 'Proj.\nRevenue', valueColor: const Color(0xFF16A34A))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                               const Text('Your Listings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                               const Spacer(),
                               Text('${mySpots.length} spaces', style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }
                    
                    final spot = mySpots[index - 1];
                    final isBooked = ParkingService().isSpotCurrentlyBooked(spot.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _spaceCard(
                        spot: spot,
                        isBooked: isBooked,
                        onStats: () => context.push('/main'), 
                        // Link Edit Button - pass all existing data including imageUrl
                        onEdit: () => context.push(Uri(path: '/host/new-space', queryParameters: {
                          'edit': 'true',
                          'id': spot.id,
                          'title': spot.title,
                          'addr': spot.subtitle,
                          'price': spot.pricePerHour.toString(),
                          'lat': spot.pos.latitude.toString(),
                          'lng': spot.pos.longitude.toString(),
                          if (spot.imageUrl != null) 'imageUrl': spot.imageUrl!,
                          'accessMethod': spot.accessMethod,
                        }).toString()),
                        onToggleVisibility: () async {
                          await ParkingService().toggleSpotVisibility(spot.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(spot.isVisible ? 'Ο χώρος κρύφτηκε' : 'Ο χώρος είναι πλέον εμφανής')),
                            );
                          }
                        },
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Διαγραφή Χώρου'),
                              content: Text('Είσαι σίγουρος ότι θέλεις να διαγράψεις "${spot.title}";'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Ακύρωση'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Διαγραφή'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ParkingService().deleteSpot(spot.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ο χώρος διαγράφηκε.')),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/host/new-space'),
            backgroundColor: AppColors.primary,
            elevation: 4,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('List Space', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        );
      }
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
    required bool isBooked,
    required VoidCallback onStats,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onToggleVisibility,
  }) {
    return Opacity(
      opacity: spot.isVisible ? 1.0 : 0.6, // Dim hidden spots
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    // Placeholder for real image
                    child: spot.imageUrl != null 
                        ? Image.network(spot.imageUrl!, fit: BoxFit.cover)
                        : const Center(child: Icon(Icons.image_outlined, size: 64, color: Colors.black12)),
                  ),
                ),
                // Status Badge - BOOKED, FREE, or HIDDEN
                Positioned(
                  top: 12,
                  left: 12,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isBooked ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isBooked ? 'BOOKED' : 'FREE', 
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                      if (!spot.isVisible) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'HIDDEN', 
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Hide/Unhide button (top right, next to delete)
                Positioned(
                  top: 12,
                  right: 48,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    radius: 16,
                    child: IconButton(
                      icon: Icon(
                        spot.isVisible ? Icons.visibility : Icons.visibility_off,
                        size: 18,
                      ),
                      onPressed: onToggleVisibility,
                      color: spot.isVisible ? Colors.blue : Colors.grey,
                      padding: EdgeInsets.zero,
                      tooltip: spot.isVisible ? 'Απόκρυψη' : 'Εμφάνιση',
                    ),
                  ),
                ),
                // Delete button (top right)
                Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    radius: 16,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: onDelete,
                      color: Colors.red,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            
          // Info Area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(spot.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.2)),
                          const SizedBox(height: 4),
                          Text(spot.subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('€${spot.pricePerHour.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        const Text('/ ώρα', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onStats,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Στατιστικά'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: onEdit,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Επεξεργασία'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),  // Close Container
    );  // Close Opacity
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
