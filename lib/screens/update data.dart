/*
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'Signup page.dart';

class UpdateUserScreen extends StatefulWidget {
  final Signup user;

  UpdateUserScreen({required this.user});

  @override
  _UpdateUserScreenState createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.user.Username);
    emailController = TextEditingController(text: widget.user.Email);
  }

  void updateUser() {
    final updatedData = {
      'Username': usernameController.text.trim(),
      'Email': emailController.text.trim(),
      'Password': passwordController.text.trim(),
    };

    FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(widget.user.uid)
        .update(updatedData)
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User updated successfully')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateUser,
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
*/
