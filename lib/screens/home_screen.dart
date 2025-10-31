import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Zakat App',
                      style: Get.theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Calculate and manage your Zakat easily',
                      style: Get.theme.textTheme.bodyMedium?.copyWith(
                        color: Get.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: Get.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  icon: Icons.calculate,
                  title: 'Calculate Zakat',
                  color: Get.theme.colorScheme.primary,
                  onTap: () {
                    // Navigate to calculator
                  },
                ),
                _buildActionCard(
                  icon: Icons.history,
                  title: 'View History',
                  color: Get.theme.colorScheme.secondary,
                  onTap: () {
                    // Navigate to history
                  },
                ),
                _buildActionCard(
                  icon: Icons.account_balance,
                  title: 'Zakat Info',
                  color: Get.theme.colorScheme.tertiary,
                  onTap: () {
                    Get.snackbar(
                      'Info',
                      'Zakat information coming soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                _buildActionCard(
                  icon: Icons.share,
                  title: 'Share App',
                  color: Get.theme.colorScheme.primaryContainer,
                  onTap: () {
                    Get.snackbar(
                      'Share',
                      'Share functionality coming soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Activity',
              style: Get.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('No recent activity'),
                      subtitle: const Text('Your Zakat calculations will appear here'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Get.theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

