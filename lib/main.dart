import 'package:flutter/material.dart';
import 'app/app.dart';
import 'db_init.dart' if (dart.library.io) 'db_init_desktop.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDb();
  runApp(const App());
}
