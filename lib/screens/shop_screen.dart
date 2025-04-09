import 'package:flutter/material.dart';
import '../utils/ad_manager.dart';

class ShopScreen extends StatelessWidget {
  final bool isParent;

  const ShopScreen({super.key, required this.isParent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Glitter Color Pack'),
                  trailing: Text(isParent ? '\$1.99' : '100 Coins'),
                  onTap: () {
                    if (!isParent) {
                      // Add coin purchase logic
                    }
                  },
                ),
                if (isParent)
                  const ListTile(
                    title: Text('Crayon Set (Physical)'),
                    trailing: Text('\$9.99'),
                  ),
              ],
            ),
          ),
          if (!isParent)
            ElevatedButton(
              onPressed: () {
                AdManager.showRewardedAd(onReward: (reward) {
                  // Add 50 coins
                  print('Earned $reward coins');
                });
              },
              child: const Text('Watch Ad for 50 Coins'),
            ),
          if (isParent) AdManager.getBannerAd(), // Now returns a Widget
        ],
      ),
    );
  }
}