// models/coloring_page.dart
class ColoringPage {
  final String id;
  final String category;
  final String svgPath;
  int partsCount; // Removed 'final' to make it mutable
  final String funFact;
  final bool isNumbered;

  ColoringPage({
    required this.id,
    required this.category,
    required this.svgPath,
    this.partsCount = 0, // Default to 0, updated dynamically
    required this.funFact,
    required this.isNumbered,
  });
}

 List<ColoringPage> pages = [
  // Animals
  ColoringPage(
    id: '1',
    category: 'Animals',
    svgPath: 'assets/coloring_pages/parrot.svg',
    funFact: 'Parrots love spicy chili!',
    isNumbered: true,
  ),
  ColoringPage(
    id: '2',
    category: 'Animals',
    svgPath: 'assets/coloring_pages/unicorn.svg',
    funFact: 'Unicorns are mystical creatures!',
    isNumbered: true,
  ),
  ColoringPage(
    id: '3',
    category: 'Animals',
    svgPath: 'assets/coloring_pages/babyndragon.svg',
    funFact: 'Dragons are mysterious creatures!',
    isNumbered: true,
  ),
  ColoringPage(
    id: '4',
    category: 'Animals',
    svgPath: 'assets/coloring_pages/mermaid.svg',
    funFact: 'Mermaids can swim in the ocean!',
    isNumbered: true,
  ),
  ColoringPage(
    id: '5',
    category: 'Flowers',
    svgPath: 'assets/coloring_pages/parrot.svg',
    funFact: 'Roses come in many colors!',
    isNumbered: true,
  ),
  ColoringPage(
    id: '6',
    category: 'Fruits',
    svgPath: 'assets/coloring_pages/unicorn.svg',
    funFact: 'Apples can be red or green!',
    isNumbered: true,
  ),
  ColoringPage(
    id: '7',
    category: 'Insects',
    svgPath: 'assets/coloring_pages/baby_dragon.svg',
    funFact: 'Butterflies have colorful wings!',
    isNumbered: true,
  ),
  ColoringPage(
    id: '8',
    category: 'Plants',
    svgPath: 'assets/coloring_pages/mermaid.svg',
    funFact: 'Cacti can survive in deserts!',
    isNumbered: true,
  ),
  ColoringPage(
    id: '9',
    category: 'Vegetables',
    svgPath: 'assets/coloring_pages/parrot.svg',
    funFact: 'Carrots are good for your eyes!',
    isNumbered: true,
  ),
];