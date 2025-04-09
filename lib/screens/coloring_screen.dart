import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:xml/xml.dart';
import '../models/coloring_page.dart';
import '../widgets/color_palette.dart';
import '../utils/storage_manager.dart';
import '../utils/sound_manager.dart';
import '../utils/svg_path_painter.dart';
import '../utils/svg_renderer.dart';

class ColoringScreen extends StatefulWidget {
  final ColoringPage page;
  const ColoringScreen({super.key, required this.page});

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> {
  Map<String, Color> coloredParts = {};
  Color selectedColor = Colors.red;
  List<String> pathIds = [];
  List<XmlElement> svgPaths = [];
  Map<String, Rect> pathBounds = {};
  bool showFunFact = false;
  bool isNumbered = true;
  int completedPages = 0;
  late ConfettiController _confettiController;
  double svgWidth = 300;
  double svgHeight = 400;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    loadProgress();
    parseSvg();
    SoundManager.toggleMusic(true);
  }

  void loadProgress() async {
    final progress = await StorageManager.getProgress();
    setState(() {
      completedPages = progress['completedPages'] ?? 0;
      coloredParts = Map<String, Color>.from(progress['coloredParts'] ?? {});
      isNumbered = widget.page.isNumbered && completedPages < 5;
    });
  }

  void parseSvg() async {
    try {
      final svgString = await DefaultAssetBundle.of(context).loadString(widget.page.svgPath);
      final document = XmlDocument.parse(svgString);

      // Recursively find all <path> elements
      svgPaths = [];
      void findPaths(XmlElement element) {
        if (element.name.local == 'path') {
          final pathData = element.getAttribute('d');
          if (pathData != null && pathData.isNotEmpty) {
            svgPaths.add(element);
          }
        }
        for (final child in element.childElements) {
          findPaths(child);
        }
      }

      final root = document.rootElement;
      findPaths(root);

      // Extract SVG viewport size
      final svgElement = document.getElement('svg');
      final viewBox = svgElement?.getAttribute('viewBox')?.split(' ') ?? ['0', '0', '300', '400'];
      svgWidth = double.tryParse(viewBox[2]) ?? 300;
      svgHeight = double.tryParse(viewBox[3]) ?? 400;

      pathIds.clear();
      pathBounds.clear();
      for (int i = 0; i < svgPaths.length; i++) {
        final pathId = 'path_$i';
        pathIds.add(pathId);

        final pathData = svgPaths[i].getAttribute('d') ?? '';
        final painter = SvgPathPainter(
          pathData: pathData,
          color: Colors.transparent,
          size: Size(svgWidth, svgHeight),
          svgWidth: svgWidth,
          svgHeight: svgHeight,
        );
        final bounds = painter.computeBounds();
        pathBounds[pathId] = bounds;
      }

      widget.page.partsCount = pathIds.length;
      setState(() {});
    } catch (e) {
      // In a production app, use a logging framework instead
    }
  }

  void onPathTapped(String pathId) {
    setState(() {
      coloredParts[pathId] = selectedColor;
      if (coloredParts.length == pathIds.length) {
        showFunFact = true;
        completedPages++;
        _confettiController.play();
        StorageManager.saveProgress({
          'completedPages': completedPages,
          'coloredParts': coloredParts,
        });
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    SoundManager.toggleMusic(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.page.category),
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Expanded(
                    child: CustomSvgPicture(
                      svgPath: widget.page.svgPath,
                      coloredParts: coloredParts,
                      pathIds: pathIds,
                      svgPaths: svgPaths,
                      pathBounds: pathBounds,
                      isNumbered: isNumbered,
                      onPathTapped: onPathTapped,
                      constraints: constraints,
                      svgWidth: svgWidth,
                      svgHeight: svgHeight,
                      selectedColor: selectedColor,
                    ),
                  ),
                  ColorPalette(
                    onColorSelected: (color) {
                      setState(() => selectedColor = color);
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
                color: Colors.white.withOpacity(0.9),
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

class CustomSvgPicture extends StatelessWidget {
  final String svgPath;
  final Map<String, Color> coloredParts;
  final List<String> pathIds;
  final List<XmlElement> svgPaths;
  final Map<String, Rect> pathBounds;
  final bool isNumbered;
  final Function(String) onPathTapped;
  final BoxConstraints constraints;
  final double svgWidth;
  final double svgHeight;
  final Color selectedColor;

  const CustomSvgPicture({
    super.key,
    required this.svgPath,
    required this.coloredParts,
    required this.pathIds,
    required this.svgPaths,
    required this.pathBounds,
    required this.isNumbered,
    required this.onPathTapped,
    required this.constraints,
    required this.svgWidth,
    required this.svgHeight,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base SVG rendered by SvgRenderer
        SizedBox(
          width: constraints.maxWidth * 0.8,
          height: constraints.maxHeight * 0.6,
          child: SvgRenderer(svgPath: svgPath),
        ),
        // Colored paths with tap detection
        ...pathIds.asMap().entries.map((entry) {
          final index = entry.key;
          final pathId = entry.value;
          final color = coloredParts[pathId] ?? Colors.transparent;
          final pathData = svgPaths[index].getAttribute('d') ?? '';
          final bounds = pathBounds[pathId] ?? Rect.zero;

          return Positioned(
            left: bounds.left * (constraints.maxWidth * 0.8 / svgWidth),
            top: bounds.top * (constraints.maxHeight * 0.6 / svgHeight),
            width: bounds.width * (constraints.maxWidth * 0.8 / svgWidth),
            height: bounds.height * (constraints.maxHeight * 0.6 / svgHeight),
            child: GestureDetector(
              onTap: () {
                if (isNumbered) {
                  onPathTapped(pathId);
                } else {
                  final nextPath = pathIds.firstWhere(
                    (pathId) => !coloredParts.containsKey(pathId),
                    orElse: () => '',
                  );
                  if (nextPath.isNotEmpty) {
                    onPathTapped(nextPath);
                  }
                }
              },
              child: CustomPaint(
                painter: SvgPathPainter(
                  pathData: pathData,
                  color: color,
                  size: Size(
                    constraints.maxWidth * 0.8,
                    constraints.maxHeight * 0.6,
                  ),
                  svgWidth: svgWidth,
                  svgHeight: svgHeight,
                ),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          );
        }),
        // Numbered labels (scattered)
        if (isNumbered)
          ...pathIds.asMap().entries.map((entry) {
            final index = entry.key;
            final pathId = entry.value;
            final bounds = pathBounds[pathId] ?? Rect.zero;
            final offsetX = (index % 3 - 1) * 10.0;
            final offsetY = ((index % 5) - 2) * 10.0;
            final centroidX = (bounds.left + bounds.width / 2 + offsetX);
            final centroidY = (bounds.top + bounds.height / 2 + offsetY);

            return Positioned(
              left: centroidX * (constraints.maxWidth * 0.8 / svgWidth),
              top: centroidY * (constraints.maxHeight * 0.6 / svgHeight),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: coloredParts[pathId] != null ? Colors.transparent : Colors.white.withOpacity(0.7),
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
    );
  }
}