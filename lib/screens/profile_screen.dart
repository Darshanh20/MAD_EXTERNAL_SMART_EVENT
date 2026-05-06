import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Profile content with avatar, user details, and action rows.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar and user identity section.
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 52),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'John Doe',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'johndoe@example.com',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 28),
              // Action list section.
              Card(
                child: Column(
                  children: [
                    _ProfileTile(
                      icon: Icons.edit,
                      title: 'Edit Profile',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _ProfileTile(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _ProfileTile(
                      icon: Icons.security,
                      title: 'Privacy & Security',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _ProfileTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _ProfileTile(
                      icon: Icons.logout,
                      title: 'Logout',
                      iconColor: Colors.red,
                      titleColor: Colors.red,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: titleColor, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }
}
