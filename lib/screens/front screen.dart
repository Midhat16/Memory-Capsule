import 'package:flutter/material.dart';
import 'Signup page.dart';


class Frnt extends StatefulWidget {
  @override
  _FrntState createState() => _FrntState();
}

class _FrntState extends State<Frnt> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NewAccountScreen()),
      );
    });
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
          child: Image.asset(
            'assets/images/logo2.png',
            width: 400,
            height: 450,
          ),
        ),
      ),
    );
  }
}
