import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaint_management_system/parts/app_drawer.dart';
import 'package:complaint_management_system/utility/app.dart';
import 'package:flutter/material.dart';
import 'complaint_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComplaintListPage extends StatefulWidget {
  const ComplaintListPage({super.key});

  @override
  _ComplaintListPageState createState() => _ComplaintListPageState();
}

class _ComplaintListPageState extends State<ComplaintListPage> {
  String selectedCategory = 'Academic';
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

  final List<String> complaintCategories = [
    'Academic',
    'Hostel',
    'Washroom',
    'Classroom',
    'Bathroom',
    'Electricity',
    'Water',
    'Beds',
  ];

  final Map<String, IconData> categoryIcons = {
    'Academic': Icons.school,
    'Hostel': Icons.bed,
    'Washroom': Icons.wash,
    'Classroom': Icons.class_,
    'Bathroom': Icons.bathtub,
    'Electricity': Icons.electrical_services,
    'Water': Icons.water_drop,
    'Beds': Icons.king_bed,
  };

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
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: isAdmin
            ? null
            : Container(
                width: 65,
                height: 65,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 1, 31, 93),
                      Color.fromARGB(255, 45, 110, 240)
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
                "Complaint Categories",
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
              elevation: 0,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 252, 252, 254),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Filter by Complaint Type",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100, width: 1.2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 2,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                    dropdownColor: Colors.white,
                    items: complaintCategories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(categoryIcons[value],
                                size: 20, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('complains')
                      .where('type', isEqualTo: selectedCategory)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No complaints found.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    final complaints = snapshot.data!.docs;

                    return ListView.separated(
                      itemCount: complaints.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final complaint = complaints[index];
                        final icon =
                            categoryIcons[selectedCategory] ?? Icons.report;
                        final description =
                            complaint['description'] ?? 'No description';

                        return ComplaintCard(
                          index + 1, // serial number
                          description,
                          icon,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final int serialNumber;
  final String title;
  final IconData icon;

  const ComplaintCard(this.serialNumber, this.title, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 26, color: Colors.blue.shade600),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Complaint #$serialNumber",
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
