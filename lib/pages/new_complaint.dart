import 'package:complaint_management_system/parts/app_drawer.dart';
import 'package:complaint_management_system/utility/app.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../parts/info_widget.dart';

class NewComplaintPage extends StatefulWidget {
  const NewComplaintPage({super.key});

  @override
  State<NewComplaintPage> createState() => _NewComplaintPageState();
}

class _NewComplaintPageState extends State<NewComplaintPage> {
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedType = 'Hostel';
  final List<String> _complaintTypes = [
    'Academic',
    'Hostel',
    'Washroom',
    'Classroom',
    'Bathroom',
    'Electricity',
    'Water',
    'Beds',
  ];
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      final data = snap.docs.first.data() as Map<String, dynamic>;
      setState(() {
        isAdmin = (data['role'] ?? '') == 'admin';
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

  Future<void> _submitComplaint() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final email = user.email;

    // Fetch user's registration number
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get()
        .then((snapshot) => snapshot.docs.first);

    final registrationNo = userDoc['Registration #'] ?? 'Unknown';

    // Add complaint
    final complaintRef =
        await FirebaseFirestore.instance.collection('complains').add({
      'type': _selectedType,
      'description': _descriptionController.text.trim(),
      'email': email,
      'registrationNo': registrationNo,
      'uid': uid,
      'timestamp': Timestamp.now(),
    });

    // Add notification
    await FirebaseFirestore.instance.collection('notifications').add({
      'uid': uid,
      'title': 'Complaint Submitted',
      'subtitle': 'Your complaint has been submitted and is under progress.',
      'complaintId': complaintRef.id,
      'timestamp': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Complaint Submitted!"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isAdmin
          ? null
          : Container(
              width: 65,
              height: 65,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 2, 36, 106),
                    Color.fromARGB(255, 28, 99, 240),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => _onItemTapped(context, 2),
                icon: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
      drawer: AppDrawer(),
      bottomNavigationBar: AppWithBottomNavigation(
        selectedIndex: 0,
        onItemTapped: (index) => _onItemTapped(context, index),
      ),
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
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
          child: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            title: const Text(
              "New Complaint",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.notification);
                },
              ),
            ],
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Complaint Title",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.report,
                    color: Color.fromARGB(255, 26, 35, 126)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 26, 35, 126)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 26, 35, 126), width: 2),
                ),
              ),
              items: _complaintTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedType = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 15),
            const Text(
              "Complaint Description",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Describe your complaint...",
                prefixIcon: const Icon(Icons.description,
                    color: Color.fromARGB(255, 26, 35, 126)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color.fromARGB(255, 26, 35, 126)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 26, 35, 126), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 25),
            GradientButton(
              text: "Submit Complaint",
              onPressed: _submitComplaint,
            )
          ],
        ),
      ),
    );
  }
}
