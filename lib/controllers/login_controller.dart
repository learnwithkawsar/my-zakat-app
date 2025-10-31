import 'package:get/get.dart';
import '../screens/dashboard_screen.dart';

class LoginController extends GetxController {
  final usernameController = ''.obs;
  final passwordController = ''.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  // Dummy credentials
  final String dummyUsername = 'admin';
  final String dummyPassword = 'password123';

  void setUsername(String value) {
    usernameController.value = value;
  }

  void setPassword(String value) {
    passwordController.value = value;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    if (usernameController.value.isEmpty || passwordController.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter both username and password',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (usernameController.value == dummyUsername &&
        passwordController.value == dummyPassword) {
      isLoading.value = false;
      Get.snackbar(
        'Success',
        'Login successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );
      // Navigate to dashboard
      Get.offAll(() => DashboardScreen());
    } else {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Invalid username or password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    }
  }
}

