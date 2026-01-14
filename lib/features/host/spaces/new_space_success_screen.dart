import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewSpaceSuccessScreen extends StatelessWidget {
  final Map<String, String> params;
  const NewSpaceSuccessScreen({super.key, this.params = const {}});

  @override
  Widget build(BuildContext context) {
    final title = params['title'] ?? 'Parking';
    final addr = params['addr'] ?? 'Αθήνα';
    final price = params['price'] ?? '5';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 54),
              ),
              const SizedBox(height: 16),
              const Text('🎉 Τέλεια!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              const Text(
                'Ο χώρος σας είναι έτοιμος\nπρος ενοικίαση',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Το listing σας είναι πλέον ενεργό\nκαι ορατό σε χιλιάδες χρήστες\nτου ParkNow!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF16A34A), width: 2),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: const Color(0xFFEFF4FF), borderRadius: BorderRadius.circular(14)),
                      child: const Center(child: Text('P', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2563EB)))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF6B7280)),
                              const SizedBox(width: 6),
                              Expanded(child: Text(addr, style: const TextStyle(color: Color(0xFF6B7280)), maxLines: 1)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(14)),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, size: 10, color: Color(0xFF16A34A)),
                          SizedBox(width: 6),
                          Text('Live', style: TextStyle(color: Color(0xFF16A34A))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Τιμή ενοικίασης', style: TextStyle(color: Color(0xFF2563EB))),
                    const SizedBox(height: 6),
                    Text('€$price/ώρα', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                  ],
                ),
              ),

              const Spacer(),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/main'),
                  child: const Text('Οι Χώροι μου'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.go('/main'),
                child: const Text('Επόμενα βήματα'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
