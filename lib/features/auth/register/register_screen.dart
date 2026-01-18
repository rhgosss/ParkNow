// lib/features/auth/register/register_screen.dart
import 'dart:async';
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
  bool _autoValidate = false;
  
  // TASK 2: Async email validation state
  Timer? _emailDebounce;
  bool _isCheckingEmail = false;
  String? _emailAsyncError;
  bool _emailVerified = false;

  @override
  void initState() {
    super.initState();
    // Set up listener for email field with debounce
    emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailDebounce?.cancel();
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passController.dispose();
    pass2Controller.dispose();
    super.dispose();
  }

  // TASK 2: Debounced email check
  void _onEmailChanged() {
    // Cancel previous timer
    _emailDebounce?.cancel();
    
    final email = emailController.text.trim();
    
    // Reset states
    setState(() {
      _emailAsyncError = null;
      _emailVerified = false;
    });
    
    // Validate format first
    if (email.isEmpty || _validateEmailFormat(email) != null) {
      return;
    }
    
    // Start debounce timer (500ms delay)
    _emailDebounce = Timer(const Duration(milliseconds: 500), () {
      _checkEmailExists(email);
    });
  }

  Future<void> _checkEmailExists(String email) async {
    setState(() => _isCheckingEmail = true);
    
    try {
      final exists = await AuthRepository().emailExists(email);
      if (mounted) {
        setState(() {
          _isCheckingEmail = false;
          if (exists) {
            _emailAsyncError = 'Αυτό το email χρησιμοποιείται ήδη';
            _emailVerified = false;
          } else {
            _emailAsyncError = null;
            _emailVerified = true;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingEmail = false;
          // Don't block on network errors, but don't mark as verified
          _emailVerified = false;
        });
      }
    }
  }

  // Real-time validators for TextFormField
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Το όνομα είναι υποχρεωτικό';
    if (value.length < 2) return 'Το όνομα πρέπει να έχει τουλάχιστον 2 χαρακτήρες';
    return null;
  }

  String? _validateEmailFormat(String? value) {
    if (value == null || value.isEmpty) return 'Το email είναι υποχρεωτικό';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Μη έγκυρη μορφή email';
    return null;
  }

  // Combined email validator (format + async)
  String? _validateEmail(String? value) {
    // First check format
    final formatError = _validateEmailFormat(value);
    if (formatError != null) return formatError;
    
    // Then check async error
    if (_emailAsyncError != null) return _emailAsyncError;
    
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

  // TASK 2: Check if Next button should be enabled
  bool get _canProceed {
    if (_isLoading || _isCheckingEmail) return false;
    if (_emailAsyncError != null) return false;
    // Email must be verified as unique (or at least checked without error)
    final email = emailController.text.trim();
    if (email.isNotEmpty && _validateEmailFormat(email) == null && !_emailVerified) {
      return false; // Email not yet verified
    }
    return true;
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

    // TASK 2: Block if email not verified or has error
    if (_emailAsyncError != null) {
      setState(() => _errorMessage = _emailAsyncError);
      return;
    }
    
    if (!_emailVerified && !_isCheckingEmail) {
      // Email hasn't been checked yet, trigger check now
      final email = emailController.text.trim();
      setState(() => _isLoading = true);
      await _checkEmailExists(email);
      setState(() => _isLoading = false);
      
      if (_emailAsyncError != null) {
        setState(() => _errorMessage = _emailAsyncError);
        return;
      }
    }

    final fullName = '${nameController.text.trim()} ${lastNameController.text.trim()}'.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passController.text;

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

              // Email field with real-time async validation (TASK 2)
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
                  // TASK 2: Show loading indicator or check mark
                  suffixIcon: _buildEmailSuffix(),
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

              // TASK 2: Button disabled while checking or if email error
              PrimaryButton(
                text: _isLoading || _isCheckingEmail ? 'Έλεγχος...' : 'Συνέχεια',
                onPressed: (_isLoading || !_canProceed) ? null : _validateAndProceed,
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

  // TASK 2: Build suffix icon for email field
  Widget? _buildEmailSuffix() {
    final email = emailController.text.trim();
    
    // Don't show anything if email is empty or invalid format
    if (email.isEmpty || _validateEmailFormat(email) != null) {
      return null;
    }
    
    if (_isCheckingEmail) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    
    if (_emailAsyncError != null) {
      return Icon(Icons.cancel, color: Colors.red.shade600);
    }
    
    if (_emailVerified) {
      return Icon(Icons.check_circle, color: Colors.green.shade600);
    }
    
    return null;
  }
}
