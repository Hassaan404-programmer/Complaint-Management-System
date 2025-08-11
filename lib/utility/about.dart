import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About App"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "CMS – UET Rachna",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "This application is developed for UET Rachna students and staff to easily manage complaints in a structured and efficient way.\n\n"
                "🔹 Developed using Flutter and Firebase.\n"
                "🔹 Allows users to register, login, and reset passwords.\n"
                "🔹 Users can submit new complaints, track them by ID, and view their status.\n"
                "🔹 Complaints are stored in Firebase Firestore.\n"
                "🔹 Authentication is managed with Firebase Auth.\n"
                "🔹 Clean and modern interface with easy navigation.\n\n"
                "© 2025 UET Rachna Campus. All rights reserved.",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
