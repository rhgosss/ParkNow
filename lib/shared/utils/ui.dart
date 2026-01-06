// lib/shared/utils/ui.dart
import 'package:flutter/material.dart';

void comingSoon(BuildContext context, [String text = 'Σύντομα διαθέσιμο']) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), duration: const Duration(milliseconds: 900)),
  );
}
