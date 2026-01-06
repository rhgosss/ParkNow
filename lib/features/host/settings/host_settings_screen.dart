import 'package:flutter/material.dart';
import '../../../core/state/app_state_scope.dart';

class HostSettingsScreen extends StatelessWidget {
  const HostSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Αλλαγή ρόλου (parker/host)'),
              onTap: () => app.switchRole(),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Έξοδος'),
              onTap: () => app.logout(),
            ),
          ],
        ),
      ),
    );
  }
}
