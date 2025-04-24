import 'package:flutter/material.dart';
import 'package:pinpong/play_with_comp.dart';


void main() {
  runApp(const PingPongApp());
}

class PingPongApp extends StatelessWidget {
  const PingPongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PingPong',
      home: PingPongHomePage(),
    );
  }
}

class PingPongHomePage extends StatelessWidget {
  const PingPongHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/pingpong.webp',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'PingPong',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStyledButton(
                      context,
                      label: 'Play with Computer',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PlayWithComputerScreen()),
                        );
                      }
                    ),
                    const SizedBox(width: 20),
                    _buildStyledButton(
                      context,
                      label: 'Play Snake & Ladder',
                      onPressed: () {
                        // Add your navigation logic here
                      },
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStyledButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      child: Text(label),
    );
  }
}
