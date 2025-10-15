import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/custom_bottom_nav_bar.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/auth/controller/auth_controller.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/qr_verify/controller/transaction_controller.dart';
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
        ChangeNotifierProvider(create: (context) => TransactionController()),
      ],
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Railway Ticket Verification',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          appBarTheme: AppBarTheme(
            elevation: 2,
            centerTitle: true,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          scaffoldBackgroundColor: Colors.grey[50],
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: Consumer<AuthController>(
          builder: (context, authController, _) {
            return authController.isAuthorized
                ? const CustomBottomNavBar()
                : const LogoScreen();
          },
        ),
      ),
    );
  }
}
