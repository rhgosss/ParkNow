import 'package:flutter/material.dart';
import '../home/home_tab.dart';
import '../search/results_list_screen.dart';
import '../bookings/bookings_tab.dart';
import '../profile/profile_tab.dart';
import '../../core/theme/app_colors.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  final pages = const [
    HomeTab(),
    ResultsListScreen(showBack: false),
    BookingsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (v) => setState(() => index = v),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Αρχική'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Αναζήτηση'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Κρατήσεις'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Προφίλ'),
        ],
      ),
    );
  }
}
