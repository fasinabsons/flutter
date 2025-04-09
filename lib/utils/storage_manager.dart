import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  static Future<void> saveProgress(Map<String, dynamic> progress) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('progress', progress.toString());
  }

  static Future<Map<String, dynamic>> getProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('progress') != null ? {} : {};
  }
}