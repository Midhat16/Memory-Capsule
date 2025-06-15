import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CapsuleDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> capsule;

  CapsuleDetailsScreen({required this.capsule});

  @override
  _CapsuleDetailsScreenState createState() => _CapsuleDetailsScreenState();
}

class _CapsuleDetailsScreenState extends State<CapsuleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _dateController;

  String? _imageBase64;
  final _database = FirebaseDatabase.instance.ref().child('timeCapsules');

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.capsule['title'] ?? '');
    _descController = TextEditingController(text: widget.capsule['description'] ?? '');
    _dateController = TextEditingController(text: widget.capsule['unlockDate'] ?? '');
    _imageBase64 = widget.capsule['imagepath'];
  }

  Future<void> _updateCapsule() async {
    if (!_formKey.currentState!.validate()) return;

    final capsuleId = widget.capsule['id'];
    if (capsuleId == null || capsuleId.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Capsule ID is missing.")));
      return;
    }

    Map<String, dynamic> updateData = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'unlockDate': _dateController.text.trim(),
      'imagepath': _imageBase64 ?? '',
    };

    try {
      await _database.child(capsuleId).update(updateData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Capsule Updated')));
      Navigator.pop(context);
    } catch (e) {
      print('Error updating: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating capsule')));
    }
  }

  Future<void> _deleteCapsule() async {
    final capsuleId = widget.capsule['id'];
    if (capsuleId == null || capsuleId.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Capsule ID is missing.")));
      return;
    }

    try {
      await _database.child(capsuleId).remove();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Capsule Deleted')));
      Navigator.pop(context);
    } catch (e) {
      print('Error deleting: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete capsule')));
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final imageBytes = await picked.readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(imageBytes);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imageBase64 = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Capsule Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade900,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          IconButton(icon: Icon(Icons.delete, color: Colors.white), onPressed: _deleteCapsule),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                      labelText: 'Title'
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Title is required' : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Description is required' : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Unlock Date (DD/MM/YYYY)'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
                      });
                    }
                  },
                  validator: (value) => value == null || value.trim().isEmpty ? 'Date is required' : null,
                ),
                SizedBox(height: 20),
                if (_imageBase64 != null && _imageBase64!.isNotEmpty)
                  Column(
                    children: [
                      Text("Image:", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Center(
                        child: Image.memory(
                          base64Decode(_imageBase64!),
                          width: screenWidth * 0.4,
                          height: screenWidth * 0.5,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(onPressed: _pickImage, child: Text("Change")),
                          TextButton(onPressed: _removeImage, child: Text("Remove")),
                        ],
                      ),
                    ],
                  )
                else
                  Center(child: TextButton(onPressed: _pickImage, child: Text("Add Image"))),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateCapsule,
                  child: Text("Update Capsule", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade900),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}