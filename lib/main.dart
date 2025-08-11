import 'pages/complaint_list_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Make sure this file exists and is generated
import 'pages/notification_page.dart';
import 'utility/app.dart';
import 'package:flutter/material.dart';
import 'pages/start_page.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/forgot_password.dart';
import 'pages/main_complaint.dart';
import 'pages/complaint_status.dart';
import 'pages/new_complaint.dart';
import 'pages/complaint_id.dart';
import 'pages/view_complaints.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/greeting_splash.dart';
import 'theme/theme.dart';

import 'parts/app_drawer.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ComplaintApp());
}

class ComplaintApp extends StatelessWidget {
  const ComplaintApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'complain management system',
          theme: MyAppTheme.lightTheme,
          darkTheme: MyAppTheme.darkTheme,
          themeMode: mode,
          onGenerateRoute: AppRoutes.generateRoute,
          home: const SplashOrHome(),
        );
      },
    );
  }
}

class SplashOrHome extends StatefulWidget {
  const SplashOrHome({Key? key}) : super(key: key);
  @override
  State<SplashOrHome> createState() => _SplashOrHomeState();
}

class _SplashOrHomeState extends State<SplashOrHome> {
  bool? isFirstOpen;

  @override
  void initState() {
    super.initState();
    _checkFirstOpen();
  }

  Future<void> _checkFirstOpen() async {
    final prefs = await SharedPreferences.getInstance();
    isFirstOpen = prefs.getBool('hasOpenedBefore') ?? false;
    if (!isFirstOpen!) {
      // First time open, show StartPage
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => StartPage()),
        );
      }
      prefs.setBool('hasOpenedBefore', true);
    } else {
      _routeAfterSplash();
    }
  }

  Future<void> _routeAfterSplash() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Show greeting splash page
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => GreetingSplashPage()),
        );
      }
    } else {
      // Not logged in, go to login
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF011F5D),
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
