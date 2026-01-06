import 'package:flutter/widgets.dart';
import 'app_state.dart';

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    if (scope?.notifier == null) {
      throw Exception('AppStateScope not found');
    }
    return scope!.notifier!;
  }
}
