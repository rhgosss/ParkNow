// lib/features/search/search_overlay_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchOverlayScreen extends StatelessWidget {
  const SearchOverlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Αναζήτηση')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Περιοχή / Διεύθυνση...',
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.search),
                ),
                onSubmitted: (query) {
                  // Pass query to results screen
                  context.push('/results?q=$query'); 
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/filters'),
                      icon: const Icon(Icons.tune),
                      label: const Text('Φίλτρα'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/results'), // Show all if clicked
                      icon: const Icon(Icons.list),
                      label: const Text('Όλα τα αποτελέσματα'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Expanded(
                child: Center(child: Text('Hint: γράψε μια περιοχή και πάτα “Αποτελέσματα”')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
