import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 50,
              backgroundColor: Get.theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 50,
                color: Get.theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Admin User',
              style: Get.theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'admin@zakat.app',
              style: Get.theme.textTheme.bodyMedium?.copyWith(
                color: Get.theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Personal Information'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Get.snackbar(
                        'Info',
                        'Personal information coming soon',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Get.snackbar(
                        'Info',
                        'Change password coming soon',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Notifications'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Get.snackbar(
                        'Info',
                        'Notifications settings coming soon',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Get.snackbar(
                        'Info',
                        'Language settings coming soon',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

