import 'package:flutter/material.dart';
import '../utils/sound_manager.dart';

class ColorPalette extends StatefulWidget {
  final Function(Color) onColorSelected;
  const ColorPalette({super.key, required this.onColorSelected});

  @override
  State<ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette> {
  final List<Color> fullPalette = [
    Colors.red, Colors.pink, Colors.orange, Colors.yellow,
    Colors.green, Colors.teal, Colors.blue, Colors.indigo,
    Colors.purple, Colors.brown, Colors.grey, Colors.black,
    const Color(0xFFFFC0CB), const Color(0xFF00FFFF), const Color(0xFF8B4513),
    const Color(0xFFFA8072), const Color(0xFF00FF7F), const Color(0xFFDA70D6),
    const Color(0xFFFFFFE0), const Color(0xFFB0E0E6), const Color(0xFFFFD700),
    const Color(0xFF4682B4), const Color(0xFFDEB887), const Color(0xFFFFE4C4),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(12),
        height: 300,
        child: GridView.count(
          crossAxisCount: 6,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: fullPalette.map((color) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _selectColor(color);
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: selectedColor == color ? Colors.black : Colors.white,
                    width: 2,
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
          spacing: 6,
          children: recentColors.map((color) {
            return GestureDetector(
              onTap: () => _selectColor(color),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selectedColor == color ? Colors.black : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: () => _openColorPicker(context),
          icon: const Icon(Icons.palette_outlined),
          label: const Text("Choose Color"),
        )
      ],
    );
  }
}
