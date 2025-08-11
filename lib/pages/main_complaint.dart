import 'package:complaint_management_system/pages/complaint_id.dart';
import 'package:complaint_management_system/pages/complaint_list_page.dart';
import 'package:complaint_management_system/pages/complaint_status.dart';
import 'package:complaint_management_system/pages/new_complaint.dart';
import 'package:complaint_management_system/pages/profile_page.dart';
import 'package:complaint_management_system/pages/settings_page.dart';
import 'package:complaint_management_system/parts/app_drawer.dart';
import 'package:complaint_management_system/utility/app.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_page.dart';

class ComplaintHomePage extends StatefulWidget {
  const ComplaintHomePage({super.key});

  @override
  State<ComplaintHomePage> createState() => _ComplaintHomePageState();
}

class _ComplaintHomePageState extends State<ComplaintHomePage> {
  String? _role;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
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
          _role = data['role'];
          _loading = false;
        });
        if (data['role'] == 'admin') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminPage()),
            );
          });
        }
      } else {
        setState(() {
          _role = null;
          _loading = false;
        });
      }
    } else {
      setState(() {
        _role = null;
        _loading = false;
      });
    }
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        _handleHomeNavigation(context);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.List);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.NewComplain);
        break;
      case 3:
        _handleIndex3(context);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.Profile);
        break;
    }
  }

  Future<void> _handleHomeNavigation(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();
    final data = snap.docs.isNotEmpty
        ? snap.docs.first.data() as Map<String, dynamic>
        : {};
    final role = (data['role'] ?? '').toString();
    if (role == 'admin') {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.Admin, (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.Status, (route) => false);
    }
  }

  Future<void> _handleIndex3(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();
    final data = snap.docs.isNotEmpty
        ? snap.docs.first.data() as Map<String, dynamic>
        : {};
    final role = (data['role'] ?? '').toString();
    if (role == 'admin') {
      Navigator.pushNamed(context, AppRoutes.Id);
    } else {
      Navigator.pushNamed(context, AppRoutes.announcement);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // If admin, the redirect will already have happened
    // Only show user dashboard for non-admins
    return Scaffold(
      drawer: AppDrawer(),
      bottomNavigationBar: AppWithBottomNavigation(
        selectedIndex: 0, // Default index
        onItemTapped: (index) => _onItemTapped(context, index),
      ),
      appBar: AppBar(
        title: const Text(
          "Complaint Management",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: const [SizedBox(width: 8)],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 20, 22, 26),
              Color.fromARGB(255, 56, 66, 84)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 15),
                // Title Box
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Your Voice",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(color: Colors.white70, fontSize: 24),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Our First Priority",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Single Box for Complaint Options
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ComplaintOption(
                        text: "Complaint Status",
                        icon: Icons.list_alt,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ComplaintStatusPage()),
                        ),
                      ),
                      Divider(color: Colors.grey[300]),
                      ComplaintOption(
                        text: "New Complaint",
                        icon: Icons.add_circle_outline,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewComplaintPage()),
                        ),
                      ),
                      Divider(color: Colors.grey[300]),
                      ComplaintOption(
                        text: "Complaint ID",
                        icon: Icons.tag,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ComplaintIDPage()),
                        ),
                      ),
                      Divider(color: Colors.grey[300]),
                      ComplaintOption(
                        text: "View Complaints",
                        icon: Icons.rate_review,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ComplaintListPage()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Widget for Complaint Options
class ComplaintOption extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const ComplaintOption({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 30, color: const Color(0xFF1A237E)),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      onTap: onTap,
    );
  }
}
