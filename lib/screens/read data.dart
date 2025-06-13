/*
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:untitled3/screens/update%20data.dart';
import 'Signup page.dart';

class readData extends StatefulWidget {
  const readData({super.key});

  @override
  State<readData> createState() => _readDataState();
}

class _readDataState extends State<readData> {
  final _databaseref = FirebaseDatabase.instance.ref().child('users');
  late List<Signup> alldata = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    _databaseref.onValue.listen((event) {
      final data = event.snapshot.value;
      final List<Signup> fetchedUsers = [];

      if (data != null && data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            final signup = Signup.fromMap(Map<String, dynamic>.from(value));
            signup.uid = key;
            fetchedUsers.add(signup);
          }
        });
        setState(() {
          alldata = fetchedUsers;
        });
      }
    });
  }

  void deleteData(String uid) {
    FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(uid)
        .remove()
        .then((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Data deleted')));
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting data')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User List")),
      body: ListView.builder(
        itemCount: alldata.length,
        itemBuilder: (context, index) {
          final user = alldata[index];
          return ListTile(
            title: Text(user.Username),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.Email),

              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteData(user.uid);
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateUserScreen(user: user),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
*/
