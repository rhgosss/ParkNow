import 'package:flutter/widgets.dart';
import 'app_state.dart';

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    if (scope?.notifier == null) {
      throw Exception('AppStateScope not found');
    }
    return scope!.notifier!;
  }
}
