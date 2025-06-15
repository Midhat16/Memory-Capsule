import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Signup page.dart';
import 'home screens.dart';

class Log extends StatefulWidget {
  const Log({super.key});

  @override
  State<Log> createState() => _LogState();
}

class _LogState extends State<Log> {
  final TextEditingController feild1 = TextEditingController();
  final TextEditingController feild2 = TextEditingController();

  bool _obscureText = true;
  bool _emailError = false;
  bool _passwordError = false;
  String? _emailErrorText;
  String? _passwordErrorText;

  Future<void> login() async {
    setState(() {
      _emailError = feild1.text.isEmpty;
      _passwordError = feild2.text.isEmpty;
      _emailErrorText = _emailError ? 'Email required' : null;
      _passwordErrorText = _passwordError ? 'Password required' : null;
    });

    if (_emailError || _passwordError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields')),
      );
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: feild1.text.trim(),
        password: feild2.text.trim(),
      );

      final uid = userCredential.user?.uid;
      if (uid != null && mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('uid', uid);
        await prefs.setString('email', feild1.text.trim());
        await prefs.setString('password', feild2.text.trim());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in successfully')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException code: ${e.code}');

      if (!mounted) return;

      setState(() {
        _emailError = false;
        _passwordError = false;
        _emailErrorText = null;
        _passwordErrorText = null;

        if (e.code == 'user-not-found') {
          _emailError = true;
          _emailErrorText = 'No account found for this email';
        } else if (e.code == 'wrong-password') {
          _passwordError = true;
          _passwordErrorText = 'Incorrect password';
        } else if (e.code == 'invalid-credential') {
          _passwordError = true;
          _passwordErrorText = 'Email or password is incorrect';
        } else {
          _emailError = true;
          _emailErrorText = 'Login error: ${e.code}';
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.message}')),
      );
    }
  }

    Future<void> forgotPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset email sent to $email")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    }
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
          child: Card(
            elevation: 200,
            color: Colors.transparent,
            shadowColor: Colors.black,
            child: Container(
              width: size.width * 0.7,
              height: size.height * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.grey),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Colors.green.shade900),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Member Login',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  /// Email Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email', style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: feild1,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Enter your Email',
                          labelStyle: const TextStyle(color: Colors.white),
                          prefixIcon: const Icon(Icons.mail_outline_rounded, color: Colors.white),
                          errorText: _emailError ? _emailErrorText : null,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      /// Password Field
                      const Text('Password', style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: feild2,
                        obscureText: _obscureText,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Enter Password',
                          labelStyle: const TextStyle(color: Colors.white),
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          errorText: _passwordError ? _passwordErrorText : null,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          final email = feild1.text.trim();
                          if (email.isNotEmpty) {
                            forgotPassword(email);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please enter your email")),
                            );
                          }
                        },
                        child: const Text("Forgot Password?", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade900),
                    child: const Text('Login', style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NewAccountScreen()),
                    ),
                    child: const Text(
                      "Don't have Account? Create Account",
                      style: TextStyle(color: Colors.white),
                    ),
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
