// lib/features/filters/filters_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
<<<<<<< HEAD
import '../../shared/widgets/chip_pill.dart';
=======
import '../../shared/widgets/app_widgets.dart';
>>>>>>> main

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  RangeValues price = const RangeValues(0, 20);

  bool covered = false;
  bool guard = false;
  bool cameras = false;
  bool lighting = false;
  bool evCharging = false;

  String type = 'Υπόγειο';

  void reset() {
    setState(() {
      price = const RangeValues(0, 20);
      covered = false;
      guard = false;
      cameras = false;
      lighting = false;
      evCharging = false;
      type = 'Υπόγειο';
    });
  }

  void apply() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Φίλτρα'),
        actions: [
          TextButton(
            onPressed: reset,
            child: const Text('Καθαρισμός'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: [
            const Text('Τιμή ανά ώρα', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Από: ${price.start.toStringAsFixed(0)}€', style: const TextStyle(color: Color(0xFF6B7280))),
                      const Spacer(),
                      Text('Έως: ${price.end.toStringAsFixed(0)}€', style: const TextStyle(color: Color(0xFF6B7280))),
                    ],
                  ),
                  RangeSlider(
                    values: price,
                    min: 0,
                    max: 20,
                    divisions: 20,
                    labels: RangeLabels(
                      '${price.start.toStringAsFixed(0)}€',
                      '${price.end.toStringAsFixed(0)}€',
                    ),
                    onChanged: (v) => setState(() => price = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            const Text('Παροχές', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            _checkRow(text: 'Στεγασμένο', value: covered, onChanged: (v) => setState(() => covered = v)),
            _checkRow(text: 'Φύλακας 24/7', value: guard, onChanged: (v) => setState(() => guard = v)),
            _checkRow(text: 'Κάμερες', value: cameras, onChanged: (v) => setState(() => cameras = v)),
            _checkRow(text: 'Φωτισμός', value: lighting, onChanged: (v) => setState(() => lighting = v)),
            _checkRow(text: 'Ηλεκτρικός Φορτιστής', value: evCharging, onChanged: (v) => setState(() => evCharging = v)), // New!
            const SizedBox(height: 18),

            const Text('Τύπος χώρου', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ChipPill(
                    text: 'Υπόγειο',
                    selected: type == 'Υπόγειο',
                    onTap: () => setState(() => type = 'Υπόγειο'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChipPill(
                    text: 'Εξωτερικός',
                    selected: type == 'Εξωτερικός',
                    onTap: () => setState(() => type = 'Εξωτερικός'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ChipPill(
                    text: 'Ιδιωτικός',
                    selected: type == 'Ιδιωτικός',
                    onTap: () => setState(() => type = 'Ιδιωτικός'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChipPill(
                    text: 'Δημόσιος',
                    selected: type == 'Δημόσιος',
                    onTap: () => setState(() => type = 'Δημόσιος'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: const Text('Εφαρμογή φίλτρων', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkRow({
    required String text,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(text),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: const Color(0xFF2563EB),
    );
  }
}
<<<<<<< HEAD

=======
>>>>>>> main
