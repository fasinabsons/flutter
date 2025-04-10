import 'package:flutter/material.dart';
import 'reward_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  GalleryScreenState createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> works = ['Parrot (In Progress)', 'Parrot (Completed)'];
  final List<String> badges = ['Beginner Artist'];
  final List<String> futureBadges = ['Color Master'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          tabs: const [
            Tab(text: 'Works'),
            Tab(text: 'Achievements'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Works Tab
              ListView.builder(
                itemCount: works.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.image),
                    title: Text(works[index]),
                  );
                },
              ),
              // Achievements Tab
              GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: badges.length + futureBadges.length,
                itemBuilder: (context, index) {
                  final isEarned = index < badges.length;
                  final badge = isEarned ? badges[index] : futureBadges[index - badges.length];
                  return GestureDetector(
                    onTap: () {
                      if (isEarned) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RewardScreen(badge: badge),
                          ),
                        );
                      }
                    },
                    child: Opacity(
                      opacity: isEarned ? 1.0 : 0.2,
                      child: Card(
                        child: Center(child: Text(badge)),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}