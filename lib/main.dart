import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/auth/auth_controller.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/home/home_screen.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/logo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthController()),
      ],
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthController>(
          builder: (context, authController, _) {
            return authController.isAuthorized
                ? const HomeScreen()
                : LogoScreen();
          },
        ),
      ),
    );
  }
}
