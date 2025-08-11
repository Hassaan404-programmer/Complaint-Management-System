import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'complaint_status.dart';
import 'admin_page.dart';

class GreetingSplashPage extends StatefulWidget {
  const GreetingSplashPage({super.key});

  @override
  State<GreetingSplashPage> createState() => _GreetingSplashPageState();
}

class _GreetingSplashPageState extends State<GreetingSplashPage> {
  String? userName;
  String? randomQuote;
  final List<String> quotes = [
    "The best way to get started is to quit talking and begin doing.",
    "Success is not in what you have, but who you are.",
    "Opportunities don't happen, you create them.",
    "Don't watch the clock; do what it does. Keep going.",
    "Great things never come from comfort zones.",
    "Dream it. Wish it. Do it.",
    "Stay positive, work hard, make it happen."
  ];

  @override
  void initState() {
    super.initState();
    _initGreeting();
  }

  Future<void> _initGreeting() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('uid', isEqualTo: user.uid)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          userName =
              data.containsKey('Full name') ? data['Full name'] : user.email;
        });

        // Check if user is admin and route accordingly
        final userRole = data.containsKey('role') ? data['role'] : '';
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          if (userRole == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AdminPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ComplaintStatusPage()),
            );
          }
        }
      } else {
        setState(() {
          userName = user.email;
        });
        setState(() {
          randomQuote = quotes[Random().nextInt(quotes.length)];
        });
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ComplaintStatusPage()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 1, 31, 93),
              Color.fromARGB(255, 45, 110, 240)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: userName != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: Image.asset(
                  "Images/rcet.png",
                  height: 90,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              AnimatedOpacity(
                opacity: userName != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1200),
                child: userName != null
                    ? Text(
                        'Welcome back, $userName!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : const SizedBox.shrink(),
              ),
              if (randomQuote != null) ...[
                const SizedBox(height: 18),
                AnimatedOpacity(
                  opacity: randomQuote != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 1600),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      '"$randomQuote"',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
              if (userName == null)
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
