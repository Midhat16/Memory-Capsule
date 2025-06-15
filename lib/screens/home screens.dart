import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Capsule Detail Screen.dart';
import 'profile page.dart';
import 'theme color.dart';
import 'top curve theme.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _timeCapsuleref = FirebaseDatabase.instance.ref().child('timeCapsules');
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref().child('users');
  List<Map<String, dynamic>> capsules = [];
  List<Map<String, dynamic>> unlockedCapsules = [];
  String username = "";
  bool showRedDot = false;

  @override
  void initState() {
    super.initState();
    _fetchCapsules();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');

    if (uid != null) {
      final userRef = _userRef.child(uid);
      final snapshot = await userRef.once();

      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map;
        setState(() {
          username = data['Username'] ?? '';
        });
      }
    }
  }

  void _fetchCapsules() {
    _timeCapsuleref.onValue.listen((event) {
      final rawData = event.snapshot.value;
      if (rawData is! Map) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final List<Map<String, dynamic>> upcoming = [];
      final List<Map<String, dynamic>> unlockedToday = [];

      rawData.forEach((key, value) {
        final capsule = Map<String, dynamic>.from(value);
        capsule['id'] = key;

        if (capsule['unlockDate'] != null) {
          final parts = capsule['unlockDate'].toString().split('/');
          if (parts.length == 3) {
            final day = int.tryParse(parts[0]);
            final month = int.tryParse(parts[1]);
            final year = int.tryParse(parts[2]);

            if (day != null && month != null && year != null) {
              final unlockDate = DateTime(year, month, day);
              if (unlockDate.isAfter(now)) {
                upcoming.add(capsule);
              } else if (unlockDate.year == today.year &&
                  unlockDate.month == today.month &&
                  unlockDate.day == today.day) {
                unlockedToday.add(capsule);
              }
            }
          }
        }
      });

      setState(() {
        capsules = upcoming.reversed.toList();
        unlockedCapsules = unlockedToday;
        showRedDot = unlockedToday.isNotEmpty;
      });
    });
  }

  Future<void> shareCompleteCapsule(Map<String, dynamic> capsule) async {
    final title = capsule['title'] ?? 'No Title';
    final Description = capsule['Description'] ?? 'No Message';
    final unlockDate = capsule['unlockDate'] ?? 'Unknown Date';
    final imagePath = capsule['imagepath'];

    String capsuleText = '''
📦 Memory Capsule

📌 Title: $title
📝 Message: $Description
📅 Unlocks on: $unlockDate
''';

    try {
      final tempDir = await getTemporaryDirectory();

      // Save text file
      final textFile = File('${tempDir.path}/capsule.txt');
      await textFile.writeAsString(capsuleText);

      List<XFile> filesToShare = [XFile(textFile.path)];

      // If image exists, decode and add
      if (imagePath != null && imagePath.toString().isNotEmpty) {
        final imageBytes = base64Decode(imagePath);
        final imageFile = File('${tempDir.path}/capsule_image.png');
        await imageFile.writeAsBytes(imageBytes);
        filesToShare.add(XFile(imageFile.path));
      }

      await Share.shareXFiles(filesToShare, text: 'Sharing a Memory Capsule 🎁');
    } catch (e) {
      print('Error sharing capsule: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share capsule')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        elevation: 30,
        title: Row(
          children: [
            Image.asset('assets/images/pic.png', height: 80),
            SizedBox(width: 10),
            Text("Home", style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.white, size: 29),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Unlocked Capsules'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: unlockedCapsules.isEmpty
                            ? Text("No unlocked capsules yet.")
                            : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: unlockedCapsules
                                .map((capsule) => ListTile(title: Text(capsule['title'] ?? 'No Title')))
                                .toList(),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              showRedDot = false;
                            });
                            Navigator.pop(context);
                          },
                          child: Text("Close"),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (showRedDot)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyProfileScreen()),
              );
            },
            icon: Icon(Icons.settings, color: Colors.white, size: 29),
          )

        ],
      ),
      body: Stack(
        children: [
          CustomPaint(
            size: Size(size.width, 200),
            painter: TopCurvePainter(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome 👋", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Hello, $username", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text("What memories will you preserve today?"),
                  SizedBox(height: 20),
                  Text("Upcoming Capsules", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  if (capsules.isEmpty) Text("No upcoming capsules."),
                  SizedBox(
                    height: 400,
                    child: ListView.builder(
                      itemCount: capsules.length,
                      itemBuilder: (context, index) {
                        final capsule = capsules[index];
                        final imagePath = capsule['imagepath'] ?? '';

                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          color: Colors.green[50],
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: (imagePath.toString().isNotEmpty)
                                ? Image.memory(
                              base64Decode(imagePath),
                              width: 60,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                                : Icon(Icons.image),
                            title: Text(capsule['title'] ?? 'No Title'),
                            subtitle: Text("Unlocks on: ${capsule['unlockDate'] ?? 'N/A'}"),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.green.shade800),
                                  tooltip: "Update",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CapsuleDetailsScreen(capsule: capsule),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.share, color: Colors.green.shade800),
                                  tooltip: "Share",
                                  onPressed: () => shareCompleteCapsule(capsule),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create');
        },
        backgroundColor: kPrimaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: kAppBarColor,
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.white),
                onPressed: () {},
                tooltip: 'Home',
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.track_changes, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/tracker');
                },
                tooltip: 'Tracker',
              ),
            ],
          ),
        ),
      ),
    );
  }
}