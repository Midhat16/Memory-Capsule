import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'capsule models.dart';
import 'theme color.dart';
import 'top curve theme.dart';

class CreateCapsuleScreen extends StatefulWidget {
  @override
  _CreateCapsuleScreenState createState() => _CreateCapsuleScreenState();
}

class _CreateCapsuleScreenState extends State<CreateCapsuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? base64image;

  final DatabaseReference _databaseref =
  FirebaseDatabase.instance.ref().child('timeCapsules');

  Future<void> imagepicker() async {
    final result = await _picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      final bytes = await result.readAsBytes();
      setState(() {
        _image = result;
        base64image = base64Encode(bytes);
      });
    }
  }

  void _createCapsule() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null || base64image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an image.')),
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      final newCapsule = _databaseref.push();

      TimeCapsule capsule = TimeCapsule(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        unlockDate: _dateController.text.trim(),
        imagepath: base64image!,
        userID: user?.uid ?? '',
        id: newCapsule.key ?? '',
      );

      await newCapsule.set(capsule.toMap());

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Success"),
          content: Text("Time Capsule Created Successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Widget _previewImageWidget() {
    if (_image == null) {
      return Text("No image selected", style: TextStyle(color: Colors.grey));
    }
    return kIsWeb
        ? Image.network(_image!.path, height: 200)
        : Image.file(File(_image!.path), height: 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFACE8B4),
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text('Create your Time Capsule',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 200),
            painter: TopCurvePainter(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Enter title here',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? 'Required to be filled' : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Enter Description Here.....',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? 'Required to be filled' : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          _dateController.text =
                          "${picked.day}/${picked.month}/${picked.year}";
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Set Unlock Date (DD/MM/YYYY)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? 'Required to be filled' : null,
                    ),
                    SizedBox(height: 10),
                    _previewImageWidget(),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: imagepicker,
                      icon: Icon(Icons.image),
                      label: Text("Select Image"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade900,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          String shareText = '''
Time Capsule
Title: ${_titleController.text}
Description: ${_descController.text}
Unlock Date: ${_dateController.text}
''';
                          Share.share(shareText);
                        }
                      },
                      icon: Icon(Icons.share),
                      label: Text("Share Capsule", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade900),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _createCapsule,
                      child: Text("Create Capsule", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade900,
                        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}