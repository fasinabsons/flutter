import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class RewardScreen extends StatefulWidget {
  final String badge;

  const RewardScreen({super.key, required this.badge});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: _controller,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [Colors.pink, Colors.yellow, Colors.green],
            shouldLoop: false,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              const SizedBox(height: 20),
              Text(
                'You unlocked: ${widget.badge}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Coloring!'),
              )
            ],
          ),
        ],
      ),
    );
  }
}
