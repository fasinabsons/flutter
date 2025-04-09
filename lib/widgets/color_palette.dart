import 'package:flutter/material.dart';
import '../utils/sound_manager.dart';

class ColorPalette extends StatefulWidget {
  final Function(Color) onColorSelected;
  const ColorPalette({super.key, required this.onColorSelected});

  @override
  State<ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette> {
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.cyan,
    Colors.indigo,
    Colors.lime,
    Colors.brown,
    Colors.grey,
    Colors.black,
  ];

  final TextEditingController _controller = TextEditingController();

  void _handleCustomColorInput() {
    final input = _controller.text.trim();
    try {
      final hex = input.startsWith('#') ? input : '#$input';
      final color = Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
      widget.onColorSelected(color);
      SoundManager.playSound('pop');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid hex color')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                SoundManager.playSound('pop');
                widget.onColorSelected(color);
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Enter hex color (e.g. FF5733)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _handleCustomColorInput,
                child: const Text('Add'),
              )
            ],
          ),
        )
      ],
    );
  }
}
