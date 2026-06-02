import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_medicine_screen.dart';
import 'screens/history_screen.dart';
import 'screens/caregiver_screen.dart';
import 'screens/medication_screen.dart';
import 'screens/main_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PillPal',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color(#8DB654),
      //     primary: const Color(0xFF8DB654),
      //   ),
      //   useMaterial3: true,
      //   fontFamily: 'Roboto', // Default standard font, can be changed later
      // ),
      // home: const HomeScreen(),
      home: const MainWrapper(),
    );
  }
}
