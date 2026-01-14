import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_widgets.dart';
import '../../core/data/parking_service.dart';

class BookingConfirmScreen extends StatelessWidget {
  final Map<String, String> params;
  const BookingConfirmScreen({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    final spotId = params['spotId']!;
    final price = double.parse(params['price']!);
    final type = params['type']!;
    final startTime = DateTime.parse(params['date']!);
    final duration = int.parse(params['duration'] ?? '1');
    
    final total = price * duration;
    final endTime = type == 'day' ? startTime.add(Duration(days: duration)) : startTime.add(Duration(hours: duration));

    final spot = ParkingService().getSpot(spotId);
    if (spot == null) return const Scaffold(body: Center(child: Text('Error')));

    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Επιβεβαίωση')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            _card(
              child: ListTile(
                title: Text(spot.title),
                subtitle: Text(spot.subtitle),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Ημερομηνία & Ώρα', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
                title: const Text('Έναρξη'),
                subtitle: Text('${startTime.day}/${startTime.month} ${startTime.hour}:00'),
              ),
            ),
            const SizedBox(height: 10),
            _card(
              child: ListTile(
                leading: const Icon(Icons.access_time, color: AppColors.primary),
                title: const Text('Λήξη'),
                subtitle: Text('${endTime.day}/${endTime.month} ${endTime.hour}:00'),
              ),
            ),
            const SizedBox(height: 14),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
<<<<<<< HEAD
                children: const [
                  Text('Σύνοψη', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 10),
                  BookingRow('8€ × 4 ώρες', '32€'),
                  SizedBox(height: 8),
                  BookingRow('Χρέωση υπηρεσίας', '3€'),
                  Divider(),
                  BookingRow('Σύνολο', '35€', highlight: true),
=======
                children: [
                  const Text('Σύνοψη', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _RowItem('€$price x $duration ${type == 'day' ? 'μέρα' : 'ώρες'}', '€${(total).toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  const _RowItem('Χρέωση υπηρεσίας', '€1.00'),
                  const Divider(),
                  _RowItem('Σύνολο', '€${(total + 1).toStringAsFixed(2)}', highlight: true),
>>>>>>> main
                ],
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              text: 'Επιβεβαίωση Κράτησης',
              onPressed: () {
                 // Pass final total to payment
                 final p = Map<String, String>.from(params);
                 p['total'] = (total + 1).toString();
                 context.push(Uri(path: '/payment', queryParameters: p).toString());
              },
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

<<<<<<< HEAD
class BookingRow extends StatelessWidget {
  final String left;
  final String right;
  final bool highlight;
  const BookingRow(this.left, this.right, {super.key, this.highlight = false});
=======
class _RowItem extends StatelessWidget {
  final String left;
  final String right;
  final bool highlight;
  const _RowItem(this.left, this.right, {this.highlight = false});
>>>>>>> main

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
