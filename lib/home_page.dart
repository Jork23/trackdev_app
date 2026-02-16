import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'centrehomepage',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF1A2B49),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}