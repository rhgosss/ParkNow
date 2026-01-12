// lib/features/booking/date_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_widgets.dart';

class DatePickerScreen extends StatefulWidget {
  final Map<String, String> params;
  const DatePickerScreen({super.key, required this.params});

  @override
  State<DatePickerScreen> createState() => _DatePickerScreenState();
}

class _DatePickerScreenState extends State<DatePickerScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int duration = 1;

  @override
  Widget build(BuildContext context) {
    final type = widget.params['type'] ?? 'hour';
    final price = double.parse(widget.params['price'] ?? '0');
    final isDaily = type == 'day';

    final total = price * duration;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('Επιλογή Κράτησης', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Date Section
                _SectionHeader(title: isDaily ? 'Ημερομηνία Άφιξης' : 'Ημερομηνία'),
                const SizedBox(height: 12),
                _SelectionCard(
                  icon: Icons.calendar_today,
                  text: '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  onTap: _pickDate,
                ),
                
                const SizedBox(height: 24),

                // Time Section (Only if hourly)
                if (!isDaily) ...[
                  const _SectionHeader(title: 'Ώρα Άφιξης'),
                  const SizedBox(height: 12),
                  _SelectionCard(
                    icon: Icons.access_time,
                    text: selectedTime.format(context),
                    onTap: _pickTime,
                  ),
                  const SizedBox(height: 24),
                ],

                // Duration Section
                _SectionHeader(title: isDaily ? 'Διάρκεια (Ημέρες)' : 'Διάρκεια (Ώρες)'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleButton(icon: Icons.remove, onTap: () => setState(() {
                        if (duration > 1) duration--;
                      })),
                      Text(
                        '$duration ${isDaily ? (duration == 1 ? 'μέρα' : 'μέρες') : (duration == 1 ? 'ώρα' : 'ώρες')}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      _CircleButton(icon: Icons.add, onTap: () => setState(() => duration++)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Sticky Bottom Bar (Airbnb Style)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('€${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(
                      '€$price / ${isDaily ? 'μέρα' : 'ώρα'}', 
                      style: const TextStyle(color: Colors.grey, decoration: TextDecoration.underline),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 140,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                       final p = Map<String, String>.from(widget.params);
                       // Construct proper ISO date
                       final dt = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
                       p['date'] = dt.toIso8601String();
                       p['duration'] = duration.toString();
                       
                       context.push(Uri(path: '/booking-confirm', queryParameters: p).toString());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE31C5F), // Airbnb Red/Pink
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Συνέχεια', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (d != null) setState(() => selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context, 
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (t != null) setState(() => selectedTime = t);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }
}

class _SelectionCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _SelectionCard({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            const Text('Αλλαγή', style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Icon(icon, size: 16, color: Colors.grey.shade700),
      ),
    );
  }
}
