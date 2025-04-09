// utils/sound_manager.dart
import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> toggleMusic(bool play) async {
    try {
      if (play) {
        // Ensure background.mp3 exists in assets/music/
        await _player.setSource(AssetSource('music/background.mp3'));
        await _player.setReleaseMode(ReleaseMode.loop); // Enable looping
        await _player.resume();
      } else {
        await _player.stop();
      }
    } catch (e) {
      // In a production app, use a logging framework instead
    }
  }

  static Future<void> playSound(String sound) async {
    try {
      // Ensure sound files (e.g., pop.mp3, yay.mp3) exist in assets/sounds/
      await _player.play(AssetSource('sounds/$sound.mp3'));
    } catch (e) {
      // In a production app, use a logging framework instead
    }
  }
}