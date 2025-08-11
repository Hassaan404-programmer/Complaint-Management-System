import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:complaint_management_system/utility/app.dart';
import '../../main.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String userName = 'Loading...';
  String userEmail = 'Loading...';
  String userRole = '';

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('user')
            .where('uid', isEqualTo: user.uid)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var userDoc = querySnapshot.docs.first;
          setState(() {
            final data = userDoc.data() as Map<String, dynamic>;
            userName =
                data.containsKey('Full name') ? data['Full name'] : 'No Name';
            userEmail = data.containsKey('Email') ? data['Email'] : 'No Email';
            userRole = data.containsKey('role') ? data['role'] : '';
          });
        } else {
          setState(() {
            userName = 'User Not Found';
            userEmail = '';
            userRole = '';
          });
        }
      }
    } catch (e) {
      print('Error fetching user info: $e');
      setState(() {
        userName = 'Error';
        userEmail = 'Error';
        userRole = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(
              userEmail,
              style: TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage("Images/smile.jpg"),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("Images/rachna.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.person,
                  text: 'Profile',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.Profile),
                ),
                _buildDivider(),
                _buildDrawerItem(
                  icon: Icons.home,
                  text: 'Home',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.Status),
                ),
                _buildDivider(),
                _buildDrawerItem(
                  icon: Icons.settings,
                  text: 'Settings',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.Settings),
                ),
                _buildDivider(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.brightness_6, color: Colors.blueAccent),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text('Dark Mode',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: themeNotifier,
                        builder: (context, mode, _) {
                          return Switch(
                            value: mode == ThemeMode.dark,
                            onChanged: (val) {
                              themeNotifier.value =
                                  val ? ThemeMode.dark : ThemeMode.light;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.exit_to_app,
                  text: 'Logout',
                  onTap: () async {
                    await FirebaseAuth.instance
                        .signOut(); // Sign out from Firebase

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes
                          .Login, // or '/login' if you're not using AppRoutes
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(thickness: 1, color: Colors.grey[300]),
    );
  }
}

class AppWithBottomNavigation extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const AppWithBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<AppWithBottomNavigation> createState() =>
      _AppWithBottomNavigationState();
}

class _AppWithBottomNavigationState extends State<AppWithBottomNavigation> {
  String userRole = '';

  @override
  void initState() {
    super.initState();
    _fetchRole();
  }

  Future<void> _fetchRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      setState(() => userRole = data['role'] ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = userRole == 'admin';
    return BottomAppBar(
      color: const Color.fromARGB(255, 255, 255, 255),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 50,
      shadowColor: Colors.black45,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavIcon(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              index: 0,
              label: 'Home',
            ),
            _buildNavIcon(
              icon: Icons.list_alt_outlined,
              activeIcon: Icons.list_alt,
              index: 1,
              label: 'List',
            ),
            const SizedBox(width: 58),
            if (isAdmin)
              _buildNavIcon(
                icon: Icons.search_outlined,
                activeIcon: Icons.search,
                index: 3,
                label: 'Search',
              )
            else
              _buildNavIcon(
                icon: Icons.campaign_outlined,
                activeIcon: Icons.campaign,
                index: 3,
                label: 'Announcements',
              ),
            _buildNavIcon(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              index: 4,
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required IconData activeIcon,
    required int index,
    required String label,
  }) {
    final isSelected = widget.selectedIndex == index;
    return GestureDetector(
      onTap: () => widget.onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            size: 28,
            color: isSelected ? Colors.black : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
