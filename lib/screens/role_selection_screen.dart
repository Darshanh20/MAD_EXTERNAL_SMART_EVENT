import 'package:flutter/material.dart';

import '../models/user.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Role')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to EVENTLY',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Are you managing an event or attending one?',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          const SignupScreen(role: UserRole.manager),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                ),
                child: Column(
                  children: [
                    const Icon(Icons.event, size: 32),
                    const SizedBox(height: 12),
                    Text(
                      'I\'m an Event Manager',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create and manage events',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          const SignupScreen(role: UserRole.participant),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer,
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 32),
                    const SizedBox(height: 12),
                    Text(
                      'I\'m a Participant',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Check in to events',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Login',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
