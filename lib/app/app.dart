import 'package:flutter/material.dart';
import '../core/state/app_state.dart';
import '../core/state/app_state_scope.dart';
import 'router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final AppState appState = AppState();

  @override
  Widget build(BuildContext context) {
    final router = createRouter(appState);

    return AppStateScope(
      notifier: appState,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
