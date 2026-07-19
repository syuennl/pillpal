import 'package:flutter/material.dart';
import '../utils/app_colours.dart';
import 'home/home_screen.dart';
import 'medication/medication_screen.dart';
import 'history_screen.dart';
import 'caregiver/caregiver_screen.dart';
import 'profile/profile_screen.dart';

import '../services/auth_service.dart';
import '../services/fcm_service.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // set up FCM here to avoid race condition
    // where Firestore receives a token update bfr Firebase Auth fully synced the new session
    final uid = AuthService().currentUser?.uid;
    if (uid != null) {
      FcmService().setup(uid);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      const MedicationScreen(),
      HistoryScreen(isActive: _selectedIndex == 2),
      const CaregiverScreen(),
      const ProfileScreen(),
    ];

    return PopScope(
      canPop:
          _selectedIndex == 0, // can only pop (exit app) when on home screen
      onPopInvokedWithResult: (didPop, result) {
        // runs when back btn clicked/screen swiped
        if (didPop) return; // if back action closed the app, stop here
        _onItemTapped(0); // if not, go back to home screen
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: screens),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.only(top: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColours.primaryGreen,
            unselectedItemColor: Colors.grey[600],

            selectedFontSize: 12,
            unselectedFontSize: 12,

            currentIndex: _selectedIndex,
            onTap: _onItemTapped, // auto pass the index

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.medication_outlined),
                activeIcon: Icon(Icons.medication),
                label: 'Medications',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Caregiver',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
