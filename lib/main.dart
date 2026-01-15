import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/data/parking_service.dart';
import 'core/data/auth_repository.dart';
import 'core/firebase/firebase_service.dart';
import 'core/data/chat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  await ParkingService().init();
  await ChatService().init();
  await AuthRepository().init();
  runApp(const App());
}
