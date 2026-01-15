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
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    try {
      await AppStateScope.of(context).login(
        emailController.text,
        passController.text,
      );
      if (context.mounted) context.go('/main');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _passwordFocusNode.requestFocus(),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Κωδικός',
              hint: '••••••••',
              controller: passController,
              obscureText: true,
              focusNode: _passwordFocusNode,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _doLogin(),
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
                onPressed: _isLoading ? null : _doLogin,
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
