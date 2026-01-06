// lib/features/auth/login/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/app_state_scope.dart';
import '../../../shared/widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 24),
            const Center(
              child: Text('ParkNow', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 24),

            AppTextField(
              label: 'Email',
              hint: 'email@example.com',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Κωδικός',
              hint: '••••••••',
              controller: passController,
              obscureText: true,
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
              text: 'Σύνδεση',
              onPressed: () {
                AppStateScope.of(context).login(
                  email: emailController.text,
                  password: passController.text,
                );
                context.go('/main');
              },
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
    );
  }
}
