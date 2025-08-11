import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaint_management_system/utility/app.dart';
import 'package:flutter/material.dart';
import 'complaint_details_page.dart';
import 'package:complaint_management_system/parts/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart' as badges;

class ComplaintStatusPage extends StatefulWidget {
  const ComplaintStatusPage({super.key});

  @override
  State<ComplaintStatusPage> createState() => _ComplaintStatusPageState();
}

class _ComplaintStatusPageState extends State<ComplaintStatusPage> {
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
      // Preserve prior behavior for admins (was using Id/search slot)
      Navigator.pushNamed(context, AppRoutes.Id);
    } else {
      Navigator.pushNamed(context, AppRoutes.announcement);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
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
              "Complaint Status",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            actions: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .where('uid', isEqualTo: uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  int count = 0;
                  if (snapshot.hasData) {
                    count = snapshot.data!.docs.length;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: badges.Badge(
                      badgeContent: Text(
                        '$count',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      showBadge: count > 0,
                      child: IconButton(
                        icon: const Icon(Icons.notifications,
                            color: Colors.white),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.notification);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('complains')
              .where('uid', isEqualTo: uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final complaints = snapshot.data!.docs;

            if (complaints.isEmpty) {
              return const Center(
                child: Text(
                  "No complaints submitted yet.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
              );
            }

            return ListView.separated(
              itemCount: complaints.length,
              separatorBuilder: (context, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                final data = complaint.data() as Map<String, dynamic>;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Complaint #${index + 1}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF1E3C72),
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (data['status'] == 'Resolved')
                                    ? Colors.green[100]
                                    : Colors.orange[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                (data['status'] == 'Resolved')
                                    ? 'Resolved'
                                    : 'Pending',
                                style: TextStyle(
                                  color: (data['status'] == 'Resolved')
                                      ? Colors.green[800]
                                      : Colors.orange[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildRow(Icons.category, data['type'] ?? 'Unknown'),
                        const SizedBox(height: 8),
                        _buildRow(Icons.description,
                            data['description'] ?? 'No description'),
                        const SizedBox(height: 8),
                        _buildRow(Icons.email, data['email'] ?? 'No email'),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 2, 46, 134),
                                  Color.fromARGB(255, 45, 110, 240)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ComplaintDetailsPage(
                                      id: complaint.id,
                                      serialNumber: index + 1,
                                    ),
                                  ),
                                );
                              },
                              icon:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              label: const Text("View Details"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[700], size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }
}
