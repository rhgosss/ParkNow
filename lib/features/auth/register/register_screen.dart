// lib/features/auth/register/register_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/auth_repository.dart';
import '../../../shared/widgets/app_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passController = TextEditingController();
  final pass2Controller = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _autoValidate = false; // Enable validation after first submit attempt

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passController.dispose();
    pass2Controller.dispose();
    super.dispose();
  }

  // Real-time validators for TextFormField
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Το όνομα είναι υποχρεωτικό';
    if (value.length < 2) return 'Το όνομα πρέπει να έχει τουλάχιστον 2 χαρακτήρες';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Το email είναι υποχρεωτικό';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Μη έγκυρη μορφή email';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Το τηλέφωνο είναι υποχρεωτικό';
    if (value.length < 10) return 'Μη έγκυρος αριθμός τηλεφώνου';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ο κωδικός είναι υποχρεωτικός';
    if (value.length < 6) return 'Ο κωδικός πρέπει να έχει τουλάχιστον 6 χαρακτήρες';
    return null;
  }

  String? _validatePasswordMatch(String? value) {
    if (value == null || value.isEmpty) return 'Επιβεβαιώστε τον κωδικό';
    if (value != passController.text) return 'Οι κωδικοί δεν ταιριάζουν';
    return null;
  }

  Future<void> _validateAndProceed() async {
    // Enable auto-validation after first attempt
    setState(() => _autoValidate = true);
    
    // Clear previous error
    setState(() => _errorMessage = null);

    // Validate form using TextFormField validators
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    final fullName = '${nameController.text.trim()} ${lastNameController.text.trim()}'.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passController.text;

    // TASK 2: Check if email already exists BEFORE navigating
    setState(() => _isLoading = true);
    try {
      final exists = await AuthRepository().emailExists(email);
      if (exists) {
        setState(() {
          _errorMessage = 'Αυτό το email χρησιμοποιείται ήδη';
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      // Continue if check fails (might be network issue)
    }
    setState(() => _isLoading = false);

    // All validations passed, go to role selection
    if (mounted) {
      context.push(Uri(path: '/role', queryParameters: {
        'email': email,
        'pass': password,
        'name': fullName,
        'phone': phone,
      }).toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Δημιούργησε λογαριασμό')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidate 
              ? AutovalidateMode.onUserInteraction 
              : AutovalidateMode.disabled,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Error message (for duplicate email)
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),

              // Name field with real-time validation
              TextFormField(
                controller: nameController,
                validator: _validateName,
                decoration: InputDecoration(
                  labelText: 'Όνομα *',
                  hintText: 'Γιώργος',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Last Name field
              TextFormField(
                controller: lastNameController,
                validator: _validateName,
                decoration: InputDecoration(
                  labelText: 'Επώνυμο *',
                  hintText: 'Παπαδόπουλος',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Email field with real-time validation
              TextFormField(
                controller: emailController,
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  hintText: 'email@example.com',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Phone field
              TextFormField(
                controller: phoneController,
                validator: _validatePhone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Τηλέφωνο *',
                  hintText: '69X XXX XXXX',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Password field with real-time validation
              TextFormField(
                controller: passController,
                validator: _validatePassword,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Κωδικός * (min 6 χαρακτήρες)',
                  hintText: '••••••••',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Confirm Password field
              TextFormField(
                controller: pass2Controller,
                validator: _validatePasswordMatch,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Επιβεβαίωση Κωδικού *',
                  hintText: '••••••••',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                text: _isLoading ? 'Έλεγχος...' : 'Συνέχεια',
                onPressed: _isLoading ? null : _validateAndProceed,
              ),

              const SizedBox(height: 16),
              Center(
                child: Text(
                  '* Υποχρεωτικά πεδία',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
