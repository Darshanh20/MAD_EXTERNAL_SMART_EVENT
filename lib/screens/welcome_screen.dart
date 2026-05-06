import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Full-screen gradient background and centered onboarding content.
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0C10), Color(0xFF171A20)],
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
                      backgroundColor: scheme.surfaceContainerHighest,
                      child: const Icon(
                        Icons.rocket_launch,
                        size: 48,
                        color: Color(0xFFF3E6C2),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // App name and tagline section.
                    Text(
                      'MyApp',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your journey starts here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: scheme.onSurface.withValues(alpha: 0.78),
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
                        foregroundColor: scheme.primary,
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
