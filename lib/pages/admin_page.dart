import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:image_picker/image_picker.dart';
import 'complaint_details_page.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:complaint_management_system/parts/app_drawer.dart';
import 'package:complaint_management_system/utility/app.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Stay on Admin dashboard
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.List);
        break;
      case 2:
        // Admin should not add new complaints; ignore or stay
        break;
      case 3:
        // Treat as search -> using Registration ID page for search
        Navigator.pushNamed(context, AppRoutes.Id);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.Profile);
        break;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      bottomNavigationBar: AppWithBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: (i) => _onNavTap(context, i),
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
            title: const Text('Admin Dashboard',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Logout',
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF4F6FA),
      body: AnimationLimiter(
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 600),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: widget,
              ),
            ),
            children: [
              _buildDashboardCard(
                icon: Icons.people,
                title: 'User Accounts',
                subtitle: 'View and manage all user accounts',
                color: Colors.blueAccent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _AdminUserAccountsPage(),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildDashboardCard(
                icon: Icons.assignment,
                title: 'Complaints',
                subtitle: 'Handle and resolve user complaints',
                color: Colors.deepPurple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _AdminComplaintsPage(),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildDashboardCard(
                icon: Icons.file_download,
                title: 'Export to Excel',
                subtitle: 'Download complaints as Excel',
                color: Colors.green,
                onTap: () => _showExportOptions(context),
              ),
              const SizedBox(height: 32),
              _buildDashboardCard(
                icon: Icons.campaign,
                title: 'Announcements',
                subtitle: 'Create and manage announcements',
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _AdminAnnouncementsPage(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 32,
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(width: 28),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 22),
          ],
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Export Complaints',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Resolved Complaints'),
                onTap: () {
                  Navigator.pop(context);
                  _exportComplaintsToExcel(context, filter: 'Resolved');
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.pending_actions, color: Colors.orange),
                title: const Text('Pending Complaints'),
                onTap: () {
                  Navigator.pop(context);
                  _exportComplaintsToExcel(context, filter: 'Pending');
                },
              ),
              ListTile(
                leading: const Icon(Icons.list, color: Colors.blue),
                title: const Text('All Complaints'),
                onTap: () {
                  Navigator.pop(context);
                  _exportComplaintsToExcel(context, filter: 'All');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportComplaintsToExcel(BuildContext context,
      {required String filter}) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Complaints'];
    // Add header row
    sheet.appendRow([
      'Complaint ID',
      'Type',
      'Description',
      'Status',
      'User Email',
      'Roll Number',
      'Timestamp'
    ]);
    // Fetch complaints from Firestore
    QuerySnapshot snapshot;
    if (filter == 'All') {
      snapshot = await FirebaseFirestore.instance.collection('complains').get();
    } else if (filter == 'Resolved') {
      snapshot = await FirebaseFirestore.instance
          .collection('complains')
          .where('status', isEqualTo: 'Resolved')
          .get();
    } else {
      snapshot = await FirebaseFirestore.instance
          .collection('complains')
          .where('status', isNotEqualTo: 'Resolved')
          .get();
    }
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      sheet.appendRow([
        doc.id,
        data['type'] ?? '',
        data['description'] ?? '',
        data['status'] ?? '',
        data['email'] ?? '',
        data['registrationNo'] ?? '',
        data['timestamp']?.toDate().toString() ?? '',
      ]);
    }
    // Save to file
    final List<int>? fileBytes = excel.encode();
    if (fileBytes == null) return;
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/complaints_export.xlsx');
    await file.writeAsBytes(fileBytes, flush: true);
    // Share or download
    await Share.shareXFiles([XFile(file.path)], text: 'Complaints Export');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Excel file exported!'), backgroundColor: Colors.green),
    );
  }
}

// --- User Accounts Page ---
class _AdminUserAccountsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Accounts'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!.docs;
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = users[index].data() as Map<String, dynamic>;
              final uid = users[index].id;
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.blueAccent),
                  title: Text(data['Full name'] ?? 'No Name'),
                  subtitle: Text(data['Email'] ?? 'No Email'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('user')
                          .doc(uid)
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User deleted.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --- Complaints Page ---
class _AdminComplaintsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complains')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final complaints = snapshot.data!.docs;
          if (complaints.isEmpty) {
            return const Center(child: Text('No complaints found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: complaints.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = complaints[index].data() as Map<String, dynamic>;
              final id = complaints[index].id;
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading:
                      const Icon(Icons.assignment, color: Colors.deepPurple),
                  title: Text(data['type'] ?? 'Unknown'),
                  subtitle: Text(data['description'] ?? ''),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Resolve'),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('complains')
                          .doc(id)
                          .update({'status': 'Resolved'});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Complaint marked as resolved.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComplaintDetailsPage(
                          id: id,
                          serialNumber: index + 1,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AdminAnnouncementsPage extends StatefulWidget {
  @override
  State<_AdminAnnouncementsPage> createState() =>
      _AdminAnnouncementsPageState();
}

class _AdminAnnouncementsPageState extends State<_AdminAnnouncementsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _postAnnouncement() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    if (title.isEmpty || message.isEmpty) return;
    await FirebaseFirestore.instance.collection('announcements').add({
      'title': title,
      'message': message,
      'timestamp': Timestamp.now(),
    });
    _titleController.clear();
    _messageController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Announcement posted'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Manage Announcements'),
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create Announcement',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Post'),
                  onPressed: _postAnnouncement,
                ),
              ),
              const Divider(height: 32),
              const Text('Recent Announcements',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('announcements')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('No announcements yet.'));
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading:
                            const Icon(Icons.campaign, color: Colors.orange),
                        title: Text(data['title'] ?? 'Announcement'),
                        subtitle: Text(data['message'] ?? ''),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
