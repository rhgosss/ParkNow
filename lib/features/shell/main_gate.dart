// lib/features/shell/main_gate.dart
import 'package:flutter/material.dart';

import '../../core/state/app_state.dart';
import '../../core/state/app_state_scope.dart';
import '../host/host_shell.dart';
import 'parker_shell.dart';

class MainGate extends StatelessWidget {
  const MainGate({super.key});

  @override
  Widget build(BuildContext context) {
    final role = AppStateScope.of(context).role;
    return role == UserRole.host ? const HostShell() : const ParkerShell();
  }
}
