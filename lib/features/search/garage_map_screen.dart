import 'package:flutter/material.dart';
import 'garage_map_tab.dart';

class GarageMapScreen extends StatelessWidget {
  const GarageMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: GarageMapTab()),
    );
  }
}
