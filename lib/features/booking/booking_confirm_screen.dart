import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_widgets.dart';

class BookingConfirmScreen extends StatelessWidget {
  const BookingConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Επιβεβαίωση')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            _card(
              child: const ListTile(
                title: Text('Στεγασμένη Θέση Κέντρο'),
                subtitle: Text('Κολωνάκι, Αθήνα'),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Ημερομηνία & Ώρα', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _card(
              child: const ListTile(
                leading: Icon(Icons.calendar_month_outlined, color: AppColors.primary),
                title: Text('Από'),
                subtitle: Text('16 Νοε 2025, 14:00'),
              ),
            ),
            const SizedBox(height: 10),
            _card(
              child: const ListTile(
                leading: Icon(Icons.access_time, color: AppColors.primary),
                title: Text('Έως'),
                subtitle: Text('16 Νοε 2025, 18:00'),
              ),
            ),
            const SizedBox(height: 14),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Σύνοψη', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 10),
                  BookingRow('8€ × 4 ώρες', '32€'),
                  SizedBox(height: 8),
                  BookingRow('Χρέωση υπηρεσίας', '3€'),
                  Divider(),
                  BookingRow('Σύνολο', '35€', highlight: true),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              text: 'Επιβεβαίωση Κράτησης',
              onPressed: () => context.push('/payment'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class BookingRow extends StatelessWidget {
  final String left;
  final String right;
  final bool highlight;
  const BookingRow(this.left, this.right, {super.key, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(left, style: TextStyle(color: highlight ? AppColors.text : AppColors.mutedText))),
        Text(
          right,
          style: TextStyle(
            color: highlight ? AppColors.primary : AppColors.text,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
