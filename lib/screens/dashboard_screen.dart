import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import 'home_screen.dart';
import 'zakat_calculator_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final DashboardController dashboardController = Get.put(DashboardController());

  final List<Widget> _screens = [
    const HomeScreen(),
    const ZakatCalculatorScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Obx(() => Text(_getAppBarTitle(dashboardController.currentIndex.value))),
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        foregroundColor: Get.theme.colorScheme.onPrimaryContainer,
        elevation: 0,
      ),
      body: Obx(() => _screens[dashboardController.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: dashboardController.currentIndex.value,
          onDestinationSelected: (index) {
            dashboardController.changeIndex(index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.calculate_outlined),
              selectedIcon: Icon(Icons.calculate),
              label: 'Calculator',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primaryContainer,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle,
                  size: 64,
                  color: Get.theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 8),
                Text(
                  'Zakat App',
                  style: Get.theme.textTheme.headlineSmall?.copyWith(
                    color: Get.theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome, Admin',
                  style: Get.theme.textTheme.bodyMedium?.copyWith(
                    color: Get.theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  title: 'Home',
                  onTap: () {
                    dashboardController.changeIndex(0);
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.calculate,
                  title: 'Zakat Calculator',
                  onTap: () {
                    dashboardController.changeIndex(1);
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.history,
                  title: 'History',
                  onTap: () {
                    dashboardController.changeIndex(2);
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person,
                  title: 'Profile',
                  onTap: () {
                    dashboardController.changeIndex(3);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Get.snackbar(
                      'Settings',
                      'Settings screen coming soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    Get.snackbar(
                      'Help',
                      'Help & Support coming soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    Get.snackbar(
                      'About',
                      'Zakat App v1.0.0',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () {
                    Navigator.pop(context);
                    Get.offAll(() => LoginScreen());
                    Get.snackbar(
                      'Logged Out',
                      'You have been logged out successfully',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  isLogout: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout
            ? Get.theme.colorScheme.error
            : Get.theme.colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout
              ? Get.theme.colorScheme.error
              : Get.theme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Zakat Calculator';
      case 2:
        return 'History';
      case 3:
        return 'Profile';
      default:
        return 'Zakat App';
    }
  }
}

