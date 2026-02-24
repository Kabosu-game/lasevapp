import 'package:flutter/material.dart';

class SimpleTestScreen extends StatelessWidget {
  const SimpleTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test'),
        backgroundColor: const Color(0xFF265533),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Application fonctionne!',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFF265533),
          ),
        ),
      ),
    );
  }
}
