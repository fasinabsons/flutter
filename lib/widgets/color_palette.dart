import 'package:flutter/material.dart';
import '../utils/sound_manager.dart';

class ColorPalette extends StatefulWidget {
  final Function(Color) onColorSelected;
  const ColorPalette({super.key, required this.onColorSelected});

  @override
  State<ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette> {
  final List<Color> allColors = [
    Colors.red, Colors.blue, Colors.green, Colors.yellow,
    Colors.orange, Colors.purple, Colors.pink, Colors.teal,
    Colors.brown, Colors.indigo, Colors.cyan, Colors.lime,
    Colors.amber, Colors.grey, Colors.black, Colors.white
  ];

  Color selectedColor = Colors.red;
  List<Color> recentColors = [];

  void _selectColor(Color color) {
    setState(() {
      selectedColor = color;
      recentColors.remove(color);
      recentColors.insert(0, color);
      if (recentColors.length > 8) {
        recentColors = recentColors.sublist(0, 8);
      }
    });
    SoundManager.playSound('pop');
    widget.onColorSelected(color);
  }

  void _openColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 4,
          children: allColors.map((color) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _selectColor(color);
              },
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    width: 3,
                    color: selectedColor == color ? Colors.black : Colors.transparent,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 10,
          children: recentColors.map((color) {
            return GestureDetector(
              onTap: () => _selectColor(color),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    width: 3,
                    color: selectedColor == color ? Colors.black : Colors.transparent,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        TextButton.icon(
          onPressed: () => _openColorPicker(context),
          icon: const Icon(Icons.color_lens),
          label: const Text('More Colors'),
        ),
      ],
    );
  }
}
