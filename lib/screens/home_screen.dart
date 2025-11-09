import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/borrower/screens/borrower_list_screen.dart';
import '../modules/loan/screens/loan_list_screen.dart';

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
                  icon: Icons.person,
                  title: 'Borrowers',
                  color: Get.theme.colorScheme.primary,
                  onTap: () {
                    Get.to(() => const BorrowerListScreen());
                  },
                ),
                _buildActionCard(
                  icon: Icons.account_balance_wallet,
                  title: 'Loans',
                  color: Get.theme.colorScheme.secondary,
                  onTap: () {
                    Get.to(() => const LoanListScreen());
                  },
                ),
                _buildActionCard(
                  icon: Icons.calculate,
                  title: 'Calculate Zakat',
                  color: Get.theme.colorScheme.tertiary,
                  onTap: () {
                    // Navigate to calculator
                  },
                ),
                _buildActionCard(
                  icon: Icons.history,
                  title: 'View History',
                  color: Get.theme.colorScheme.primaryContainer,
                  onTap: () {
                    // Navigate to history
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

