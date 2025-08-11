import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaint_management_system/parts/app_drawer.dart';
import 'package:complaint_management_system/utility/app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComplaintIDPage extends StatefulWidget {
  const ComplaintIDPage({super.key});

  @override
  _ComplaintIDPageState createState() => _ComplaintIDPageState();
}

class _ComplaintIDPageState extends State<ComplaintIDPage> {
  final TextEditingController _regNoController = TextEditingController();
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = false;
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

  Future<void> _searchComplaints() async {
    String regNo = _regNoController.text.trim();
    if (regNo.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('complains')
          .where('registrationNo', isEqualTo: regNo)
          .get();

      final complaints = querySnapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        _complaints = List<Map<String, dynamic>>.from(complaints);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching complaints: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                    Color.fromARGB(255, 2, 35, 100),
                    Color.fromARGB(255, 30, 90, 210),
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
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              "Track by Registration No.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _regNoController,
                decoration: const InputDecoration(
                  labelText: "Enter Registration Number",
                  prefixIcon: Icon(Icons.search,
                      color: Color.fromARGB(255, 26, 35, 126)),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 1, 31, 93),
                    Color.fromARGB(255, 45, 110, 240),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: _searchComplaints,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Search",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : _complaints.isEmpty
                    ? const Text(
                        "No complaints found for this registration number.")
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _complaints.length,
                          itemBuilder: (context, index) {
                            final complaint = _complaints[index];
                            return _buildComplaintCard(complaint);
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Type: ${complaint['type'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            const Text("Description:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              complaint['description'] ?? 'No description provided.',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text("Email: ${complaint['email'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
