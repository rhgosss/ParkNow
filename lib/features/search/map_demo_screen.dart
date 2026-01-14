import 'package:flutter/material.dart';
import 'garage_map_tab.dart';

class MapDemoScreen extends StatelessWidget {
  const MapDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: GarageMapTab()),
    );
  }
}
