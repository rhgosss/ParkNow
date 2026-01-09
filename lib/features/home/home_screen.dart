import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: t.titleLarge),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Σύνδεσε εδώ τα Figma widgets.', style: t.bodyLarge),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => context.go('/home/details?id=222-3153'),
              child: const Text('Go to Details'),
            ),

            const SizedBox(height: 12),

            // ✅ ΝΕΟ ΚΟΥΜΠΙ: Ανοίγει το "DB View" για να δεις οπτικά τους users
            ElevatedButton(
              onPressed: () => context.push('/debug/users'),
              child: const Text('DEBUG: Δες Users DB'),
            ),
          ],
        ),
      ),
    );
  }
}
