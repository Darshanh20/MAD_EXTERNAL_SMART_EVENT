import 'package:flutter/material.dart';

import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Main content area with greeting, feature cards, and a scrollable list.
    final List<_ListItemData> items = <_ListItemData>[
      const _ListItemData(
        icon: Icons.dashboard_outlined,
        title: 'Dashboard',
        subtitle: 'View your overview and key stats.',
      ),
      const _ListItemData(
        icon: Icons.calendar_today_outlined,
        title: 'Schedule',
        subtitle: 'Check what is coming next.',
      ),
      const _ListItemData(
        icon: Icons.message_outlined,
        title: 'Messages',
        subtitle: 'Catch up with recent conversations.',
      ),
      const _ListItemData(
        icon: Icons.folder_outlined,
        title: 'Files',
        subtitle: 'Open your saved documents.',
      ),
      const _ListItemData(
        icon: Icons.star_outline,
        title: 'Favorites',
        subtitle: 'Access your saved items quickly.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
              );
            },
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting section.
            Text(
              'Welcome Back, User! 👋',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Horizontally scrollable feature cards.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  _FeatureCard(icon: Icons.explore, title: 'Explore'),
                  SizedBox(width: 12),
                  _FeatureCard(icon: Icons.local_activity, title: 'Activity'),
                  SizedBox(width: 12),
                  _FeatureCard(icon: Icons.settings, title: 'Settings'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Scrollable list of items.
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final _ListItemData item = items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(item.icon)),
                      title: Text(item.title),
                      subtitle: Text(item.subtitle),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: SizedBox(
        width: 140,
        height: 104,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListItemData {
  const _ListItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
