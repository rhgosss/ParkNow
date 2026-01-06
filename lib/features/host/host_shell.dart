import 'package:flutter/material.dart';
import 'spaces/host_spaces_screen.dart';
import 'messages/host_messages_screen.dart';
import 'stats/host_stats_screen.dart';
import 'settings/host_settings_screen.dart';

class HostShell extends StatefulWidget {
  const HostShell({super.key});

  @override
  State<HostShell> createState() => _HostShellState();
}

class _HostShellState extends State<HostShell> {
  int index = 0;

  final pages = const [
    HostSpacesScreen(),
    HostMessagesScreen(),
    HostStatsScreen(),
    HostSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (v) => setState(() => index = v),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: 'Χώροι'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Μηνύματα'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
