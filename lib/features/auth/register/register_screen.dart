// lib/features/auth/register/register_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/app_state_scope.dart';
import '../../../shared/widgets/app_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passController = TextEditingController();
  final pass2Controller = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Δημιούργησε λογαριασμό')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(label: 'Όνομα', hint: 'Γιώργος', controller: nameController),
            const SizedBox(height: 12),
            AppTextField(label: 'Επώνυμο', hint: 'Παπαδόπουλος', controller: lastNameController),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Email',
              hint: 'email@example.com',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Τηλέφωνο',
              hint: '+30 69X XXX XXXX',
              controller: phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            AppTextField(label: 'Κωδικός', hint: '••••••••', controller: passController, obscureText: true),
            const SizedBox(height: 12),
            AppTextField(label: 'Επιβεβαίωση Κωδικού', hint: '••••••••', controller: pass2Controller, obscureText: true),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Εγγραφή',
              onPressed: () {
                AppStateScope.of(context).startRegister();
                context.go('/role');
              },
            ),
          ],
        ),
      ),
    );
  }
}
