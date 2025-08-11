import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaint_management_system/utility/app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Profile_Page extends StatefulWidget {
  const Profile_Page({super.key});

  @override
  State<Profile_Page> createState() => _Profile_PageState();
}

class _Profile_PageState extends State<Profile_Page> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        userData = snapshot.docs.first.data();
        profileImageUrl = userData?['profileImage'];
        isLoading = false;
      });
    }
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: userData?['Full name']);
    final phoneController = TextEditingController(text: userData?['Phone #']);
    final deptController = TextEditingController(text: userData?['Department']);
    final emailController = TextEditingController(text: userData?['Email']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name")),
              TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone")),
              TextField(
                  controller: deptController,
                  decoration: const InputDecoration(labelText: "Department")),
              TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email")),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                final snapshot = await FirebaseFirestore.instance
                    .collection('user')
                    .where('uid', isEqualTo: user.uid)
                    .limit(1)
                    .get();

                if (snapshot.docs.isNotEmpty) {
                  final docId = snapshot.docs.first.id;
                  await FirebaseFirestore.instance
                      .collection('user')
                      .doc(docId)
                      .update({
                    'Full name': nameController.text.trim(),
                    'Phone #': phoneController.text.trim(),
                    'Department': deptController.text.trim(),
                    'Email': emailController.text.trim(),
                  });
                  Navigator.pop(context);
                  fetchUserData();
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final ref =
          FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');

      await ref.putFile(file);
      final imageUrl = await ref.getDownloadURL();

      final snapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('user')
            .doc(docId)
            .update({'profileImage': imageUrl});
        setState(() {
          profileImageUrl = imageUrl;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 200,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 1, 31, 93),
                            Color.fromARGB(255, 45, 110, 240)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(60),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      child: const Center(
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 80,
                      left: MediaQuery.of(context).size.width / 2 - 50,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: profileImageUrl != null
                              ? NetworkImage(profileImageUrl!)
                              : const AssetImage("assets/profile.jpg")
                                  as ImageProvider,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(Icons.camera_alt, size: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: _editProfile,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 70),
                ProfileItem(
                    icon: Icons.person,
                    label: "Name",
                    value: userData?['Full name'] ?? 'N/A'),
                ProfileItem(
                    icon: Icons.apartment,
                    label: "Department",
                    value: userData?['Department'] ?? 'N/A'),
                ProfileItem(
                    icon: Icons.phone,
                    label: "Phone",
                    value: userData?['Phone #'] ?? 'N/A'),
                ProfileItem(
                    icon: Icons.email,
                    label: "E-Mail",
                    value: userData?['Email'] ?? 'N/A'),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Show confirmation dialog
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content:
                              const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true) {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.Start,
                            (route) => false,
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              Text(value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}
