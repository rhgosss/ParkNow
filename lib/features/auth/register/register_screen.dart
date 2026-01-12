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

  Future<void> _validateAndProceed() async {
    // Clear previous error
    setState(() => _errorMessage = null);

    // Validate all fields
    final fullName = '${nameController.text.trim()} ${lastNameController.text.trim()}'.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passController.text;
    final password2 = pass2Controller.text;

    // Name validation
    final nameError = AuthRepository.validateName(fullName);
    if (nameError != null) {
      setState(() => _errorMessage = nameError);
      return;
    }

    // Email validation
    final emailError = AuthRepository.validateEmail(email);
    if (emailError != null) {
      setState(() => _errorMessage = emailError);
      return;
    }

    // Phone validation
    final phoneError = AuthRepository.validatePhone(phone);
    if (phoneError != null) {
      setState(() => _errorMessage = phoneError);
      return;
    }

    // Password validation
    final passError = AuthRepository.validatePassword(password);
    if (passError != null) {
      setState(() => _errorMessage = passError);
      return;
    }

    // Password match
    if (password != password2) {
      setState(() => _errorMessage = 'Οι κωδικοί δεν ταιριάζουν');
      return;
    }

    // Check if email already exists
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
      // Continue if check fails
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
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Error message
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

              AppTextField(
                label: 'Όνομα *',
                hint: 'Γιώργος',
                controller: nameController,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Επώνυμο *',
                hint: 'Παπαδόπουλος',
                controller: lastNameController,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Email *',
                hint: 'email@example.com',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Τηλέφωνο *',
                hint: '69X XXX XXXX',
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Κωδικός * (min 6 χαρακτήρες)',
                hint: '••••••••',
                controller: passController,
                obscureText: true,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Επιβεβαίωση Κωδικού *',
                hint: '••••••••',
                controller: pass2Controller,
                obscureText: true,
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
