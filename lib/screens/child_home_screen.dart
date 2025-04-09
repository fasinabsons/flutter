import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/coloring_page.dart'; // Import ColoringPage
import 'coloring_screen.dart';
import 'gallery_screen.dart';
import 'settings_screen.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  _ChildHomeScreenState createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const LibraryTab(),
      const GalleryScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ColorSpark 🎨'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.photo), label: 'Gallery'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  _LibraryTabState createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = const [
    'Animals',
    'Flowers',
    'Fruits',
    'Insects',
    'Plants',
    'Vegetables',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: categories.map((category) => Tab(text: category)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: categories.map((category) {
              final filteredPages = pages.where((page) => page.category == category).toList();
              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: filteredPages.length,
                itemBuilder: (context, index) {
                  final page = filteredPages[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ColoringScreen(page: page)),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: SvgPicture.asset(page.svgPath, height: 100)),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Page ${page.id}'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}