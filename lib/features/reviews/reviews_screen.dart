import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_widgets.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Κριτικές'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.tune)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('4.9', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w700)),
                      Text('/ 5', style: TextStyle(color: AppColors.mutedText)),
                      SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.star, color: Color(0xFFFFC107)),
                        Icon(Icons.star, color: Color(0xFFFFC107)),
                        Icon(Icons.star, color: Color(0xFFFFC107)),
                        Icon(Icons.star, color: Color(0xFFFFC107)),
                        Icon(Icons.star, color: Color(0xFFFFC107)),
                      ]),
                      SizedBox(height: 6),
                      Text('100 κριτικές', style: TextStyle(color: AppColors.mutedText)),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      children: List.generate(5, (i) {
                        final star = 5 - i;
                        final value = [0.9, 0.1, 0.02, 0.01, 0.0][i];
                        final count = [87, 10, 2, 1, 0][i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              SizedBox(width: 14, child: Text('$star')),
                              const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: value,
                                    backgroundColor: const Color(0xFFE5E7EB),
                                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFFC107)),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(width: 26, child: Text('$count', textAlign: TextAlign.right)),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            PrimaryButton(text: 'Γράψε κριτική', onPressed: () {}),
            const SizedBox(height: 16),

            Row(
              children: const [
                Expanded(child: Text('Όλες οι\nκριτικές', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                SizedBox(width: 14),
                Expanded(child: TextField(decoration: InputDecoration(hintText: ''))),
              ],
            ),
            const SizedBox(height: 14),

            _reviewCard(
              initials: 'ΜΚ',
              name: 'Μαρία Κ.',
              date: '15 Νοε 2025',
              text:
                  'Εξαιρετικός χώρος! Πολύ καθαρός, ασφαλής και σε τέλεια τοποθεσία.\nΟ ιδιοκτήτης ήταν πολύ εξυπηρετικός. Σίγουρα θα ξανακλείσω!',
              likes: 12,
            ),
            const SizedBox(height: 12),
            _reviewCard(
              initials: 'ΓΠ',
              name: 'Γιώργος Π.',
              date: '12 Νοε 2025',
              text: 'Πολύ καλή εμπειρία. Γρήγορη πρόσβαση και καθαρός χώρος.',
              likes: 4,
            ),
            const SizedBox(height: 18),

            PrimaryButton(text: 'Συνέχεια', onPressed: () => context.push('/confirm')),
          ],
        ),
      ),
    );
  }

  static Widget _reviewCard({
    required String initials,
    required String name,
    required String date,
    required String text,
    required int likes,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFEFF4FF),
                child: Text(initials, style: const TextStyle(color: AppColors.primary)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600))),
              Text(date, style: const TextStyle(color: AppColors.mutedText)),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
              Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
              Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
              Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
              Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
            ],
          ),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: Color(0xFF111827))),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.thumb_up_alt_outlined, size: 18, color: AppColors.mutedText),
              const SizedBox(width: 6),
              Text('Χρήσιμη\n($likes)', style: const TextStyle(color: AppColors.mutedText)),
            ],
          ),
        ],
      ),
    );
  }
}
