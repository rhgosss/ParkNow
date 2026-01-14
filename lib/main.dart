import 'package:flutter/material.dart';
import 'app/app.dart';
<<<<<<< HEAD
import 'db_init.dart' if (dart.library.io) 'db_init_desktop.dart';
=======
import 'core/firebase/firebase_service.dart';
>>>>>>> main

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
<<<<<<< HEAD
  initializeDb();
=======
  await FirebaseService.initialize();
>>>>>>> main
  runApp(const App());
}
