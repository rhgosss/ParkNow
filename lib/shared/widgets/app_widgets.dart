// lib/shared/widgets/app_widgets.dart
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56, // Slightly taller
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE31C5F), Color(0xFFD30C4D)], // Airbnb-ish mock gradient (Pink/Red) or stick to Blue but bolder
          // Let's stick to our brand Blue but make it nicer
          // colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)], 
        ),
        borderRadius: BorderRadius.circular(12), // Less rounded, more modern
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB), // Fallback
          shadowColor: Colors.transparent, // Handled by Container
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines,
    this.onSubmitted,
    this.textInputAction,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: obscureText ? 1 : (maxLines ?? 1),
          onSubmitted: onSubmitted,
          textInputAction: textInputAction,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class ChipPill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  const ChipPill({
    super.key,
    required this.text,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF4FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: selected ? const Color(0xFF2563EB) : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
