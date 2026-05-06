import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Full-screen gradient background and centered onboarding content.
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D47A1), Color(0xFF7B1FA2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo section.
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      child: const Icon(
                        Icons.rocket_launch,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // App name and tagline section.
                    const Text(
                      'MyApp',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your journey starts here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Primary navigation button.
                    CustomButton(
                      label: 'Get Started',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const HomeScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Secondary navigation button.
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('View Profile'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
