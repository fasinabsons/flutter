import 'package:flutter/material.dart';
import 'child_home_screen.dart';
import 'parent_home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to ColorSpark 🎨',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
                );
              },
              child: const Text('I’m a Child'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ParentHomeScreen()),
                );
              },
              child: const Text('I’m a Parent'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Guest mode: Default to Child Mode
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
                );
              },
              child: const Text('Skip (Guest Mode)'),
            ),
          ],
        ),
      ),
    );
  }
}