// lib/features/shell/parker_shell.dart
import 'package:flutter/material.dart';

import '../search/results_list_screen.dart';
import '../search/garage_map_tab.dart';
import '../profile/profile_tab.dart';
import '../booking/my_bookings_screen.dart';

class ParkerShell extends StatefulWidget {
  const ParkerShell({super.key});

  @override
  State<ParkerShell> createState() => _ParkerShellState();
}

class _ParkerShellState extends State<ParkerShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const GarageMapTab(), // Map-first home screen
      const ResultsListScreen(showBack: false),
      const MyBookingsScreen(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (v) => setState(() => index = v),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Χάρτης'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Αναζήτηση'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Κρατήσεις'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Προφίλ'),
        ],
      ),
    );
  }
}
