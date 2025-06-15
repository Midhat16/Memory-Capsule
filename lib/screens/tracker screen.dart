import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'Capsule Detail Screen.dart';
import 'theme color.dart';

class CapsuleTrackerScreen extends StatefulWidget {
  @override
  _CapsuleTrackerScreenState createState() => _CapsuleTrackerScreenState();
}

class _CapsuleTrackerScreenState extends State<CapsuleTrackerScreen> {
  List<Map<String, dynamic>> allCapsules = [];
  String filter = "All"; // Options: All, Locked, Unlocked

  @override
  void initState() {
    super.initState();
    fetchCapsules();
  }

  void fetchCapsules() {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('timeCapsules');
    ref.once().then((DatabaseEvent event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        List<Map<String, dynamic>> loaded = [];
        data.forEach((key, value) {
          final capsule = Map<String, dynamic>.from(value);
          capsule['id'] = key;
          loaded.add(capsule);
        });
        setState(() {
          allCapsules = loaded;
        });
      }
    });
  }

  List<Map<String, dynamic>> getFilteredCapsules() {
    final now = DateTime.now();
    return allCapsules.where((capsule) {
      final unlockDateStr = capsule['unlockDate'] ?? '';
      if (unlockDateStr.isEmpty) return false;
      final dateParts = unlockDateStr.split('/');
      if (dateParts.length < 3) return false;

      final unlockDate = DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
      );

      if (filter == "Locked") return unlockDate.isAfter(now);
      if (filter == "Unlocked") return unlockDate.isBefore(now) || unlockDate.isAtSameMomentAs(now);
      return true;
    }).toList();
  }

  bool _isCapsuleLocked(String? unlockDate) {
    if (unlockDate == null || unlockDate.isEmpty) return true;
    final parts = unlockDate.split('/');
    if (parts.length < 3) return true;
    final unlock = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    return unlock.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    final filteredCapsules = getFilteredCapsules();

    for (var capsule in filteredCapsules) {
      String date = capsule['unlockDate'] ?? 'Unknown Date';
      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(capsule);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Capsule Tracker", style: TextStyle(color: Colors.white)),
        backgroundColor: kAppBarColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          ToggleButtons(
            isSelected: [filter == "All", filter == "Locked", filter == "Unlocked"],
            onPressed: (index) {
              setState(() {
                filter = ["All", "Locked", "Unlocked"][index];
              });
            },
            borderRadius: BorderRadius.circular(12),
            selectedColor: Colors.white,
            fillColor: Colors.green.shade900,
            children: [
              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("All Capsule")),
              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Locked")),
              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Unlocked")),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: filteredCapsules.isEmpty
                ? Center(child: Text("No capsules found"))
                : ListView(
              children: grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        entry.key,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    ...entry.value.map((capsule) {
                      final isLocked = _isCapsuleLocked(capsule['unlockDate']);
                      final imagePath = capsule['Imagepath'] ?? '';
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        color: isLocked ? Colors.red[50] : Colors.green[50],
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: isLocked ? Colors.red : Colors.green,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CapsuleDetailsScreen(capsule: capsule),
                              ),
                            );
                          },
                          leading: imagePath.isNotEmpty
                              ? Image.memory(
                            base64Decode(imagePath),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                              : Icon(Icons.image),
                          title: Text(capsule['title'] ?? 'No Title'),
                          subtitle: Text(
                            "Unlock on ${capsule['unlockDate'] ?? 'Unknown'}\n${isLocked ? '🔒 Locked' : '🔓 Unlocked'}",
                            style: TextStyle(height: 1.5),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}