import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import 'checkin_screen.dart';
import 'event_setup_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  Future<void> _loadEventsForUser() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    final role = authProvider.userRole;
    if (user == null || role == null) {
      return;
    }

    await context.read<EventProvider>().loadEvents(role: role, userId: user.id);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEventsForUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();
    final isManager = authProvider.userRole == UserRole.manager;

    return Scaffold(
      appBar: AppBar(
        title: Text(isManager ? 'My Events' : 'Available Events'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(authProvider.currentUser?.name ?? 'User'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (context) => const RoleSelectionScreenInitial(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadEventsForUser,
        child: eventProvider.events.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isManager ? Icons.event_note : Icons.search_off,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isManager
                            ? 'No events created yet'
                            : 'No events available',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isManager
                            ? 'Create your first event to get started'
                            : 'Check back later for available events',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: eventProvider.events.length,
                itemBuilder: (context, index) {
                  final event = eventProvider.events[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(event.name),
                      subtitle: Text(
                        '${event.checkedInCount}/${event.maxCapacity} checked in',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => CheckinScreen(event: event),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: isManager
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const EventSetupScreen(),
                  ),
                );
                if (mounted) {
                  await _loadEventsForUser();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('New Event'),
            )
          : null,
    );
  }
}

class RoleSelectionScreenInitial extends StatelessWidget {
  const RoleSelectionScreenInitial({super.key});

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
