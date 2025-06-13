import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:untitled3/screens/onbondring%20screens.dart';
import 'login page.dart';

class NewAccountScreen extends StatefulWidget {

   NewAccountScreen({super.key,});

  @override
  State<NewAccountScreen> createState() => _NewAccountScreenState();
}

class _NewAccountScreenState extends State<NewAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  final _auth = FirebaseAuth.instance;
  final _databaseref = FirebaseDatabase.instance.ref();

  bool options = false;
  bool _obscureText = true;
  bool _isLoading = false;

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      Signup signup = Signup(
        Username: _usernameController.text.trim(),
        Email: _emailController.text.trim(),
        Password: _passwordController.text.trim(),
        uid: uid,
      );

      // await _databaseref.child("users").push().set(signup.toMap());
          await _databaseref.child('users').child(uid).set(signup.toMap());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account Created')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating account:$e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }
  @override
  void initState() {
   /* if (widget.alldata != null) {
      final Signup= widget.alldata!;
      _usernameController.text=Signup.Username;
      _emailController.text=Signup.Email;
      _passwordController.text=Signup.Password;
    }*/
    super.initState();
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      prefixIcon: Icon(icon, color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorStyle: TextStyle(color: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade900, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.0),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,

                        child: Icon(Icons.person_add, size: 50, color: Colors.green.shade900),

                    ),
                  ),
                  SizedBox(height: 15),
                  Text('New Account',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                  Text('Username',style: TextStyle(color: Colors.white),),
                  SizedBox(height: 10,),
                  TextFormField(
                    controller: _usernameController,
                    focusNode: _usernameFocus,
                    validator: _validateUsername,
                    onFieldSubmitted: (_) {
                      if (_validateUsername(_usernameController.text) == null) {
                        FocusScope.of(context).requestFocus(_emailFocus);
                      } else {
                        setState(() {});
                      }
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: _inputDecoration('User Name', Icons.person),
                  ),
                  SizedBox(height: 10),
                  Text('Email',style: TextStyle(color: Colors.white),),
                  SizedBox(height: 10,),
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    validator: _validateEmail,
                    onFieldSubmitted: (_) {
                      if (_validateEmail(_emailController.text) == null) {
                        FocusScope.of(context).requestFocus(_passwordFocus);
                      } else {
                        setState(() {});
                      }
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Enter your Email', Icons.mail_outline_rounded),
                  ),
                  SizedBox(height: 10),
                  Text('Password',style: TextStyle(color: Colors.white),),
                  SizedBox(height: 10,),
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscureText,
                    validator: _validatePassword,
                    style: TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Enter Password', Icons.lock_outline_rounded).copyWith(
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscureText = !_obscureText),
                        icon: Icon(
                          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  ]
                  ),

                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade900, // this is the correct place
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.green.shade900)
                        : Text('Create Account', style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Log()),
                    ),
                    child: Text("Already a member? Log in", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class Signup {
  String uid;
  String Username;
  String Email;
  String Password;

  Signup({
    this.uid = '',
    required this.Username,
    required this.Email,
    required this.Password,
  });

  Map<String, dynamic> toMap() {
    return {
      'Uid':uid,
      'Username': Username,
      'Email': Email,
      'Password': Password,
    };
  }

  factory Signup.fromMap(Map<String, dynamic> map) {
    return Signup(
      Username: map['Username'] ?? '',
      Email: map['Email'] ?? '',
      Password: map['Password'] ?? '',
      uid:map['Uid']??'',
    );
  }
}

