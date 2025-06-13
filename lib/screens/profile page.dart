import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled3/screens/display setting ui.dart';
import 'package:untitled3/screens/editprofile screen.dart';
import 'package:untitled3/screens/theme%20provider.dart';
import 'package:untitled3/screens/top curve theme.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  String username = '';
  String email = '';
  String? profileImageBase64;
  final _databaseRef = FirebaseDatabase.instance.ref().child("users");

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');

    if (uid != null) {
      final snapshot = await _databaseRef.child(uid).once();
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map;
        setState(() {
          username = data['Username'] ?? '';
          email = data['Email'] ?? '';
          profileImageBase64 = data['profileImage'];
        });
      }
    }
  }

  void logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> deleteAccountWithReauth(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');

    if (uid == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    final passwordController = TextEditingController();
    final reauthConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reauthenticate'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Enter your password'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
        ],
      ),
    );

    if (reauthConfirmed != true) return;

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);
      await user.delete();
      await FirebaseDatabase.instance.ref().child('users').child(uid).remove();
      await prefs.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully.')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete your account? This action is irreversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteAccountWithReauth(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = profileImageBase64 != null ? base64Decode(profileImageBase64!) : null;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.currentTheme == AppTheme.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white)),
        title: const Text("Settings",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green.shade900,
      ),
      body: Stack(children: [
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 200),
          painter: TopCurvePainter(),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
                child: imageBytes == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 10),
              Text(username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(email, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const Editprofile()));
                  fetchUserData(); // Refresh after edit
                },
                style: TextButton.styleFrom(backgroundColor: Colors.green.shade900),
                child: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
              ),
              const Divider(thickness: 1),

              // ✅ Theme Toggle Tile
              _buildListTile(
                isDark ? Icons.dark_mode : Icons.light_mode,
                "Theme",
                subtitle: isDark ? "Dark Mode" : "Light Mode",
                onTap: () => themeProvider.toggleTheme(),
              ),

              _buildListTile(Icons.memory, "Capsule created"),
              _buildListTile(Icons.lock_open_outlined, "Capsule Unlock Reminder"),
              _buildListTile(
                Icons.display_settings_outlined,
                "Display",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DisplaySettingsScreen()),
                ),
              ),
              const Divider(thickness: 1),
              _buildListTile(Icons.delete_outline, "Delete Account",
                  onTap: () => confirmDeleteAccount(context)),
              _buildListTile(Icons.logout, "Log Out", onTap: () => logout(context)),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text("App Version 1.0", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildListTile(IconData icon, String title,
      {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ?? () {},
    );
  }
}
