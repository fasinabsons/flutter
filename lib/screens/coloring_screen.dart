// screens/coloring_screen.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/coloring_page.dart';
import '../models/vector_image.dart';
import '../widgets/color_palette.dart';
import '../utils/storage_manager.dart';
import '../widgets/svg_painter.dart';
import '../utils/svg_utils.dart';

class ColoringScreen extends StatefulWidget {
  final ColoringPage page;
  const ColoringScreen({super.key, required this.page});

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> {
  Size? _size;
  List<PathSvgItem>? _items;
  final Map<int, Rect> _pathBounds = {};
  Color selectedColor = Colors.red;
  bool showFunFact = false;
  bool isNumbered = true;
  int completedPages = 0;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    loadProgress();
    _init();
  }

  void loadProgress() async {
    final progress = await StorageManager.getProgress();
    setState(() {
      completedPages = progress['completedPages'] ?? 0;
      isNumbered = widget.page.isNumbered && completedPages < 5;
    });
  }

  Future<void> _init() async {
    final svgString = await DefaultAssetBundle.of(context).loadString(widget.page.svgPath);
    final vectorImage = getVectorImageFromStringXml(svgString);
    setState(() {
      _items = vectorImage.items;
      _size = vectorImage.size ?? const Size(300, 400);
      widget.page.partsCount = _items!.length;
      _computeBounds();
    });
  }

  void _computeBounds() {
    _pathBounds.clear();
    for (int i = 0; i < _items!.length; i++) {
      final path = _items![i].path;
      _pathBounds[i] = path.getBounds();
    }
  }

  void _onTap(int index) {
    setState(() {
      _items![index] = _items![index].copyWith(fill: selectedColor);
      if (_items!.every((item) => item.fill != null)) {
        showFunFact = true;
        completedPages++;
        _confettiController.play();
        StorageManager.saveProgress({
          'completedPages': completedPages,
          'coloredParts': _items!.asMap().map((index, item) => MapEntry(index.toString(), {
  'r': item.fill?.r,
  'g': item.fill?.g,
  'b': item.fill?.b,
  'a': item.fill?.a,
})),
        });
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.page.category),
      ),
      body: _items == null || _size == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: FittedBox(
                              child: SizedBox(
                                width: _size!.width,
                                height: _size!.height,
                                child: Stack(
                                  children: [
                                    for (int index = 0; index < _items!.length; index++)
                                      SvgPainterImage(
                                        item: _items![index],
                                        size: _size!,
                                        onTap: () {
                                          if (isNumbered) {
                                            _onTap(index);
                                          } else {
                                            final nextIndex = _items!.indexWhere((item) => item.fill == null);
                                            if (nextIndex != -1) {
                                              _onTap(nextIndex);
                                            }
                                          }
                                        },
                                      ),
                                    // Numbered labels (scattered)
                                    if (isNumbered)
                                      ..._pathBounds.entries.map((entry) {
                                        final index = entry.key;
                                        final bounds = entry.value;
                                        final offsetX = (index % 3 - 1) * 10.0;
                                        final offsetY = ((index % 5) - 2) * 10.0;
                                        final centroidX = bounds.left + bounds.width / 2 + offsetX;
                                        final centroidY = bounds.top + bounds.height / 2 + offsetY;

                                        return Positioned(
                                          left: centroidX,
                                          top: centroidY,
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _items![index].fill != null
                                                  ? Colors.transparent
                                                  : Colors.white.withValues(alpha:0.7),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        ColorPalette(
                          onColorSelected: (color) {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  colors: const [Colors.pink, Colors.yellow, Colors.green],
                  shouldLoop: false,
                ),
                if (showFunFact)
                  Center(
                    child: Container(
                      color: Colors.white.withValues(alpha:0.9),
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 40, color: Colors.amber),
                          const SizedBox(height: 10),
                          Text(
                            widget.page.funFact,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Back to Library'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class SvgPainterImage extends StatelessWidget {
  const SvgPainterImage({
    super.key,
    required this.item,
    required this.size,
    required this.onTap,
  });
  final PathSvgItem item;
  final Size size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      foregroundPainter: SvgPainter(item, onTap),
    );
  }
}