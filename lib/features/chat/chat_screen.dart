import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ctrl = TextEditingController();
  final List<_Msg> msgs = [
    _Msg(false, 'Γεια σου! Ευχαριστώ για την κράτηση. Είμαι στη διάθεσή σου για οποιαδήποτε ερώτηση!', '10:30'),
    _Msg(true, 'Γεια σου Νίκο! Θα φτάσω γύρω στις 14:00. Υπάρχει κάτι συγκεκριμένο που πρέπει να γνωρίζω;', '10:45'),
  ];

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  void send() {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => msgs.add(_Msg(true, text, _now())));
    ctrl.clear();
  }

  String _now() {
    final n = DateTime.now();
    final hh = n.hour.toString().padLeft(2, '0');
    final mm = n.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: msgs.length,
                itemBuilder: (_, i) {
                  final m = msgs[i];
                  return Align(
                    alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: m.me ? const Color(0xFF2563EB) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.text, style: TextStyle(color: m.me ? Colors.white : Colors.black87)),
                          const SizedBox(height: 6),
                          Text(m.time, style: TextStyle(color: m.me ? Colors.white70 : const Color(0xFF6B7280), fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      onSubmitted: (_) => send(),
                      decoration: InputDecoration(
                        hintText: 'Γράψε μήνυμα...',
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF2563EB),
                    child: IconButton(
                      onPressed: send,
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final bool me;
  final String text;
  final String time;
  _Msg(this.me, this.text, this.time);
}
