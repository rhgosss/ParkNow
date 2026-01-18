import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/state/app_state_scope.dart';
import '../../../core/data/parking_service.dart';
import '../../../core/data/auth_repository.dart';

/// Host Profile Screen - mirrors User profile but for Host mode
class HostProfileScreen extends StatefulWidget {
  const HostProfileScreen({super.key});

  @override
  State<HostProfileScreen> createState() => _HostProfileScreenState();
}

class _HostProfileScreenState extends State<HostProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;

  Future<void> _pickAndUploadPhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    
    if (image == null) return;

    setState(() => _uploading = true);

    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = image.mimeType ?? 'image/jpeg';
      final dataUrl = 'data:$mimeType;base64,$base64Image';
      
      await AuthRepository().updateProfilePhoto(dataUrl);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Η φωτογραφία ενημερώθηκε!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final currentUser = AppStateScope.of(context).currentUser;
    
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Προφίλ Host')),
        body: const Center(child: Text('Πρέπει να συνδεθείτε')),
      );
    }

    // Get host-specific stats
    final mySpots = ParkingService().getSpotsForOwner(currentUser.id);
    final initials = currentUser.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Προφίλ Host'),
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
                  // Profile photo with upload capability
                  GestureDetector(
                    onTap: _uploading ? null : _pickAndUploadPhoto,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primary,
                          backgroundImage: currentUser.photoUrl != null && currentUser.photoUrl!.isNotEmpty
                              ? (currentUser.photoUrl!.startsWith('data:')
                                  ? MemoryImage(base64Decode(currentUser.photoUrl!.split(',').last))
                                  : NetworkImage(currentUser.photoUrl!) as ImageProvider)
                              : null,
                          child: currentUser.photoUrl == null || currentUser.photoUrl!.isEmpty
                              ? Text(initials, style: const TextStyle(color: Colors.white, fontSize: 20))
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: _uploading
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(currentUser.name, style: t.titleMedium),
                  const SizedBox(height: 4),
                  Text(currentUser.email, style: t.bodySmall),
                  const SizedBox(height: 6),
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Host Mode',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatItem(mySpots.length.toString(), 'Χώροι'),
                      const SizedBox(width: 30),
                      const _StatItem('5.0', 'Βαθμολογία'),
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
              icon: Icons.payments_outlined, 
              text: 'Πληρωμές & Έσοδα', 
              onTap: () => context.push('/payments'),
            ),
            const SizedBox(height: 10),
            _menuTile(
              icon: Icons.swap_horiz, 
              text: 'Λειτουργία Driver', 
              onTap: () {
                AppStateScope.of(context).switchRole();
                ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Η λειτουργία άλλαξε σε Driver')),
                );
              },
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
