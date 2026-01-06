import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HostMessagesScreen extends StatelessWidget {
  const HostMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Μηνύματα'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(14)),
              child: const Text('3 νέα', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Αναζήτηση μηνυμάτων...',
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                _Chip(text: 'Όλα (4)', active: true),
                SizedBox(width: 8),
                _Chip(text: 'Αδιάβαστα (3)', active: false),
                SizedBox(width: 8),
                _Chip(text: 'Ενεργά (2)', active: false),
              ],
            ),
            const SizedBox(height: 14),

            _row(
              context,
              initials: 'ΜΚ',
              name: 'Μαρία Κωνσταντίνου',
              place: 'Κολωνάκι Parking',
              msg: 'Ευχαριστώ! Θα είμαι εκεί στις 2μμ',
              time: '10 λεπτά',
              badge: '2',
              status: 'Ενεργή κράτηση',
            ),
            _row(
              context,
              initials: 'ΓΑ',
              name: 'Γιώργος Αθανασίου',
              place: 'Σύνταγμα Plaza',
              msg: 'Γεια σας, πώς μπορώ να έχω',
              time: '2 ώρες',
              badge: '1',
            ),
            _row(
              context,
              initials: 'EM',
              name: 'Ελένη Μιχαηλίδου',
              place: 'Κολωνάκι Parking',
              msg: 'Τέλεια, σας ευχαριστώ πολύ!',
              time: '1 ημέρα',
            ),
            _row(
              context,
              initials: 'ΣΠ',
              name: 'Σταύρος Παπαδάκης',
              place: 'Πλάκα Garage',
              msg: 'Μπορώ να παρατείνω την κράτηση;',
              time: '2 ημέρες',
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: Text('Μέσος χρόνος απόκρισης:', style: TextStyle(color: Color(0xFF6B7280)))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(16)),
                  child: const Text('98%\nαπόκριση', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF16A34A))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required String initials,
    required String name,
    required String place,
    required String msg,
    required String time,
    String? badge,
    String? status,
  }) {
    return InkWell(
      onTap: () => context.push('/chat'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFEFF4FF),
              child: Text(initials),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (badge != null)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(14)),
                          child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700))),
                      Text(time, style: const TextStyle(color: Color(0xFF6B7280))),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(place, style: const TextStyle(color: Color(0xFF6B7280))),
                  const SizedBox(height: 4),
                  Text(msg, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (status != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(14)),
                      child: Text(status, style: const TextStyle(color: Color(0xFF16A34A))),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool active;
  const _Chip({required this.text, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.black87)),
    );
  }
}
