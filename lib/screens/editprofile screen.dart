import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:untitled3/screens/top%20curve%20theme.dart';

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final description = TextEditingController();
  final dob = TextEditingController();
  String? seletedoption;
  final gender = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _base64image;
  ImageProvider? _displayedImage;
  bool _isLoading = true;
  String? selectedOption;

  final _databaseRef = FirebaseDatabase.instance.ref().child("users");

  Future<void> imagepick() async {
    final result = await _picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      final bytes = await result.readAsBytes();
      setState(() {
        _image = result;
        _base64image = base64Encode(bytes);
        _displayedImage = kIsWeb
            ? NetworkImage(result.path)
            : FileImage(File(result.path)) as ImageProvider;
      });
    }
  }

  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _databaseRef.child(user.uid).update({
        'Username': username.text.trim(),
        'Email': email.text.trim(),
        'Password': password.text.trim(),
        'description': description.text.trim(),
        'dob': dob.text.trim(),
        'gender': selectedOption ?? gender.text.trim(),
        'profileImage': _base64image ?? '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Updated & Saved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade900,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green.shade900,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        dob.text = formattedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() => _isLoading = true);

    try {
      // Get current user from Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in.")),
        );
        return;
      }

      // Get data from Firebase Realtime Database
      final snapshot = await _databaseRef.child(user.uid).once();

      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          username.text = data['Username']?.toString() ?? '';
          email.text = data['Email']?.toString() ?? user.email ?? '';
          password.text = data['Password']?.toString() ?? '';
          description.text = data['description']?.toString() ?? '';
          dob.text = data['dob']?.toString() ?? '';
          gender.text = data['gender']?.toString() ?? '';
          selectedOption = data['gender']?.toString();

          // Handle profile image
          if (data['profileImage'] != null && data['profileImage'].toString().isNotEmpty) {
            _base64image = data['profileImage'].toString();
            _displayedImage = MemoryImage(base64Decode(_base64image!));
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade900,
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white)),
          title: const Text(
            'My Profile',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Stack(
            children: [
        CustomPaint(
        size: Size(MediaQuery.of(context).size.width, 200),
      painter: TopCurvePainter(),
      ),
      SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: imagepick,
                child: Stack(children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _image != null
                        ? (kIsWeb
                        ? NetworkImage(_image!.path)
                        : FileImage(File(_image!.path)) as ImageProvider)
                        : _displayedImage,
                    child: (_image == null && _displayedImage == null)
                        ? const Icon(
                        Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.shade900,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ))
                ]),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: username,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: email,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: description,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dob,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Date of Birth",
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black, // 👈 Change this color
                      width: 2.0,
                    ),
                  ),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: seletedoption,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black, // 👈 Change this color
                      width: 2.0,
                    ),
                  ),
                ),
                onChanged: (newvalue) {
                  setState(() {
                    seletedoption = newvalue;
                    gender.text = newvalue ?? '';
                  });
                },
                items: <String>['Male', 'Female', 'Prefer not to say']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveProfile,
                child: const Text(
                  "Save Profile",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade900,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
              )
            ],
          ),
        ),
      ]
        )
      );
    }
  }

