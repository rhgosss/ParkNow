// lib/features/onboarding/role_select_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/app_state.dart';
import '../../core/state/app_state_scope.dart';

class RoleSelectScreen extends StatefulWidget {
  final Map<String, String> params;
  const RoleSelectScreen({super.key, this.params = const {}});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  int selected = 0; // 0 = parker, 1 = host

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEAF2FF),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                SizedBox(height: topPadding > 0 ? 6 : 18),
                const Text(
                  'Πώς θέλεις να χρησιμοποιήσεις το\nParkNow;',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Επέλεξε τον ρόλο σου',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                ),
                const SizedBox(height: 20),

                _RoleCard(
                  selected: selected == 0,
                  icon: Icons.directions_car_filled_outlined,
                  title: 'Ψάχνω να\nπαρκάρω',
                  subtitle: 'Βρες και κράτησε\nδιαθέσιμους\nχώρους\nστάθμευσης',
                  onTap: () => setState(() => selected = 0),
                ),
                const SizedBox(height: 14),
                _RoleCard(
                  selected: selected == 1,
                  icon: Icons.apartment_outlined,
                  title: 'Είμαι Host',
                  subtitle: 'Νοίκιασε τον χώρο\nστάθμευσής σου\nκαι βγάλε εισόδημα',
                  onTap: () => setState(() => selected = 1),
                ),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFF6B7280)),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Μπορείς να αλλάξεις ρόλο ανά πάσα\nστιγμή από τις ρυθμίσεις',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final role = selected == 0 ? UserRole.driver : UserRole.host;
                      
                      if (widget.params.containsKey('email') && widget.params.containsKey('pass')) {
                         try {
                           await AppStateScope.of(context).register(
                             email: widget.params['email']!,
                             password: widget.params['pass']!,
                             role: role,
                             name: widget.params['name'] ?? 'User',
                             phone: widget.params['phone'] ?? '',
                           );
                         } catch (e) {
                           if (context.mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                             );
                           }
                           return; // Don't navigate if failed
                         }
                      }
                      
                      if (context.mounted) {
                         context.go('/main');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      selected == 0 ? 'Ξεκίνα να παρκάρεις' : 'Ξεκίνα ως Host',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB);
    final bgColor = selected ? const Color(0xFFEFF4FF) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
          boxShadow: const [
            BoxShadow(
              blurRadius: 14,
              offset: Offset(0, 6),
              color: Color(0x11000000),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: selected ? Colors.white : const Color(0xFF6B7280)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      subtitle,
                      style: const TextStyle(color: Color(0xFF6B7280), height: 1.25),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
