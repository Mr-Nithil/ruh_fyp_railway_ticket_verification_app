import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/auth/login_screen.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(80, 300, 80, 300),
            child: Image.asset(
              'assets/Sri_Lanka_Railway_logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
