import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_widgets.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEFF4FF),
                ),
                child: const Center(
                  child: Icon(Icons.location_on_outlined, color: AppColors.primary, size: 60),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.near_me_outlined, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text('Ενεργοποίηση τοποθεσίας', style: t.titleLarge),
              const SizedBox(height: 10),
              Text(
                'Επέτρεψε την πρόσβαση στην\nτοποθεσία σου για να βρούμε τους πιο\nκοντινούς διαθέσιμους χώρους\nστάθμευσης',
                textAlign: TextAlign.center,
                style: t.bodySmall,
              ),
              const SizedBox(height: 20),

              _bullet('Βρες κοντινούς χώρους', 'Δες διαθέσιμα parking γύρω σου'),
              const SizedBox(height: 14),
              _bullet('Πλοήγηση με χάρτη', 'Οδηγίες για την τοποθεσία'),
              const SizedBox(height: 14),
              _bullet('Γρήγορες προτάσεις', 'Αυτόματη αναζήτηση κοντά σου'),

              const Spacer(),

              PrimaryButton(
                text: 'Ενεργοποίηση τοποθεσίας',
                onPressed: () => context.go('/results'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.go('/results'),
                child: const Text('Παράλειψη για τώρα'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _bullet(String title, String subtitle) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 14,
          backgroundColor: Color(0xFFEFF4FF),
          child: Icon(Icons.check, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: AppColors.mutedText)),
            ],
          ),
        ),
      ],
    );
  }
}
