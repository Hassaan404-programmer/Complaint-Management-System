import 'package:complaint_management_system/parts/app_drawer.dart';
import 'package:flutter/material.dart';

class ViewComplaintsPage extends StatelessWidget {
  final List<Map<String, String>> complaints = [
    {"id": "001", "title": "Water Leakage", "review": "Resolved quickly!"},
    {
      "id": "002",
      "title": "No Internet",
      "review": "Still waiting for response."
    },
  ];

  ViewComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56), // Standard AppBar height
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 21, 51, 107),
                Color.fromARGB(255, 75, 127, 218)
              ], // Gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text(
              "Track ID by Compalaint",
              style: TextStyle(
                color: Colors.white, // Keep text color white
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            backgroundColor: Colors.transparent, // Transparent to show gradient
            centerTitle: true,
            elevation: 5,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(complaints[index]['title']!),
              subtitle: Text("Review: ${complaints[index]['review']}"),
            ),
          );
        },
      ),
    );
  }
}
