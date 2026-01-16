// lib/features/auth/login/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/auth_repository.dart';

import '../../../core/state/app_state_scope.dart';
import '../../../shared/widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _autoValidate = false;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  // Real-time validators
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Το email είναι υποχρεωτικό';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Μη έγκυρη μορφή email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ο κωδικός είναι υποχρεωτικός';
    if (value.length < 6) return 'Ο κωδικός πρέπει να έχει τουλάχιστον 6 χαρακτήρες';
    return null;
  }

  Future<void> _handleLogin() async {
    // Enable auto-validation after first attempt
    setState(() {
      _autoValidate = true;
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AppStateScope.of(context).login(
        emailController.text.trim(),
        passController.text,
      );
      if (context.mounted) context.go('/main');
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidate 
              ? AutovalidateMode.onUserInteraction 
              : AutovalidateMode.disabled,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 24),
              const Center(
                child: Text('ParkNow', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 24),

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

              AutofillGroup(
                child: Column(
                  children: [
                    // Email with real-time validation
                    TextFormField(
                      controller: emailController,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: 'Email',
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

                    // Password with real-time validation
                    TextFormField(
                      controller: passController,
                      validator: _validatePassword,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Κωδικός',
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
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/chat'),
                  child: const Text('Ξέχασες τον κωδικό;'),
                ),
              ),

              const SizedBox(height: 10),
              PrimaryButton(
                text: _isLoading ? 'Σύνδεση...' : 'Σύνδεση',
                onPressed: _isLoading ? null : _handleLogin,
              ),
              const SizedBox(height: 10),

              OutlinedButton(
                onPressed: () => context.push('/register'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                child: const Text('Εγγραφή'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
