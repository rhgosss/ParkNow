import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_widgets.dart';

class NewSpaceStep1Screen extends StatelessWidget {
  const NewSpaceStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Νέος Χώρος')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: [
            const _Progress(step: 1),
            const SizedBox(height: 18),
            const Text('Βασικές Πληροφορίες', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),

            const AppTextField(label: 'Τίτλος', hint: 'π.χ. Στεγασμένη θέση στο κέντρο'),
            const SizedBox(height: 10),
            const AppTextField(label: 'Διεύθυνση', hint: 'Οδός, Αριθμός, Περιοχή'),
            const SizedBox(height: 10),
            const AppTextField(label: 'Τιμή ανά ώρα (€)', hint: '0.00', keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            const AppTextField(label: 'Περιγραφή', hint: 'Περιγράψτε τον χώρο σας...', maxLines: 4),

            const SizedBox(height: 14),
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Center(
                child: Icon(Icons.cloud_upload_outlined, size: 34, color: Color(0xFF6B7280)),
              ),
            ),

            const SizedBox(height: 18),
            PrimaryButton(
              text: 'Επόμενο Βήμα',
              onPressed: () => context.push('/host/access'),
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
