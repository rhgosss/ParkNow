import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/models.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  int tab = 0;

  final active = const [
    BookingItem(title: 'Στεγασμένη Θέση', area: 'Κολωνάκι', date: '16 Νοε', time: '14:00-18:00', total: 35, status: 'Ενεργή'),
    BookingItem(title: 'Υπόγειο Parking', area: 'Σύνταγμα', date: '18 Νοε', time: '09:00-17:00', total: 80, status: 'Προσεχώς'),
  ];

  final history = const [
    BookingItem(title: 'Mall Parking', area: 'Μαρούσι', date: '12 Νοε', time: '10:00-14:00', total: 20, status: 'Ολοκληρωμένη'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final items = tab == 0 ? active : history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Οι Κρατήσεις μου'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.person_outline))],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => tab = 0),
                      child: Column(
                        children: [
                          Text('Ενεργές', style: TextStyle(color: tab == 0 ? AppColors.primary : AppColors.mutedText)),
                          const SizedBox(height: 8),
                          Container(height: 2, color: tab == 0 ? AppColors.primary : Colors.transparent),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => tab = 1),
                      child: Column(
                        children: [
                          Text('Ιστορικό', style: TextStyle(color: tab == 1 ? AppColors.primary : AppColors.mutedText)),
                          const SizedBox(height: 8),
                          Container(height: 2, color: tab == 1 ? AppColors.primary : Colors.transparent),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final b = items[i];
                  final pillColor = b.status == 'Ενεργή'
                      ? const Color(0xFFDCFCE7)
                      : b.status == 'Προσεχώς'
                          ? const Color(0xFFEFF4FF)
                          : const Color(0xFFE5E7EB);

                  final pillText = b.status;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
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
                              Expanded(child: Text(b.title, style: t.titleMedium)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: pillColor, borderRadius: BorderRadius.circular(16)),
                                child: Text(pillText),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(b.area, style: t.bodySmall),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.mutedText),
                              const SizedBox(width: 6),
                              Text(b.date),
                              const SizedBox(width: 12),
                              const Icon(Icons.access_time, size: 16, color: AppColors.mutedText),
                              const SizedBox(width: 6),
                              Text(b.time),
                            ],
                          ),
                          const Divider(height: 22),
                          Row(
                            children: [
                              const Text('Σύνολο', style: TextStyle(color: AppColors.mutedText)),
                              const Spacer(),
                              Text('${b.total.toStringAsFixed(0)}€', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
