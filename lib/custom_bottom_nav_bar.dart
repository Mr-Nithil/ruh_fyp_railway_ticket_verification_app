import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/home/home_screen.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/profile/profile_screen.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/settings/settings_screen.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _currentIndex = 1; // Start with Home (middle item)

  @override
  void initState() {
    super.initState();
    // Request camera permission when app opens (after login)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestCameraPermissionOnAppOpen();
    });
  }

  /// Request camera permission immediately when the main screen loads
  /// This ensures the permission appears in iOS Settings
  Future<void> _requestCameraPermissionOnAppOpen() async {
    try {
      final status = await Permission.camera.status;
      print('Camera permission status: $status');

      // Always request if not already granted
      // This covers: denied, restricted, limited, and not determined states
      if (!status.isGranted) {
        print('Requesting camera permission...');
        final result = await Permission.camera.request();
        print('Camera permission result: $result');
      } else {
        print('Camera permission already granted');
      }
    } catch (e) {
      print('Error requesting camera permission: $e');
    }
  }

  // List of screens for each tab
  final List<Widget> _screens = [
    ProfileScreen(),
    HomeScreen(),
    SettingsScreen(),
  ];

  // List of titles for the app bar
  final List<String> _titles = const ['Profile', 'Home', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.white,
        //   title: Text(
        //     _titles[_currentIndex],
        //     style: TextStyle(color: Colors.black),
        //   ),
        //   automaticallyImplyLeading: false,
        // ),
        body: _screens[_currentIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
