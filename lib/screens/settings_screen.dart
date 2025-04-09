import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shop_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool musicEnabled = false;
  bool isGooglePlayConnected = false;
  String childName = '';

  @override
  void initState() {
    super.initState();
    checkGooglePlayConnection();
  }

  void checkGooglePlayConnection() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isGooglePlayConnected = prefs.getBool('isGooglePlayConnected') ?? false;
      childName = prefs.getString('childName') ?? '';
    });
  }

  void connectGooglePlayGames() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isGooglePlayConnected = true;
      prefs.setBool('isGooglePlayConnected', true);
      prefs.setString('childName', childName);
      // Simulate saving progress to cloud (for now, just local storage)
      saveProgressToLocal();
    });
  }

  void saveProgressToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    // Placeholder: Save progress (e.g., completed pages, badges)
    prefs.setStringList('completedPages', ['Parrot', 'Lion']);
    prefs.setStringList('badges', ['Beginner Artist']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Background Music'),
              value: musicEnabled,
              onChanged: (value) {
                setState(() {
                  musicEnabled = value;
                  // Add music toggle logic
                });
              },
            ),
            ListTile(
              title: const Text('Go to Shop'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShopScreen(isParent: false)),
                );
              },
            ),
            if (!isGooglePlayConnected) ...[
              TextField(
                decoration: const InputDecoration(labelText: 'Your Name'),
                onChanged: (value) {
                  setState(() {
                    childName = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: connectGooglePlayGames,
                child: const Text('Connect with Google Play Games'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}