import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController loginController = Get.put(LoginController());
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Preset dummy credentials
    usernameController = TextEditingController(text: 'admin');
    passwordController = TextEditingController(text: 'password123');
    // Initialize controller values
    loginController.setUsername('admin');
    loginController.setPassword('password123');
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo or App Title
                  Icon(
                    Icons.account_circle,
                    size: 80,
                    color: Get.theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Zakat App',
                    textAlign: TextAlign.center,
                    style: Get.theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to continue',
                    textAlign: TextAlign.center,
                    style: Get.theme.textTheme.bodyMedium?.copyWith(
                      color: Get.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Username Field
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Get.theme.colorScheme.surfaceContainerHighest,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      loginController.setUsername(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  Obx(() => TextFormField(
                    controller: passwordController,
                    obscureText: !loginController.isPasswordVisible.value,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          loginController.isPasswordVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          loginController.togglePasswordVisibility();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Get.theme.colorScheme.surfaceContainerHighest,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      loginController.setPassword(value);
                    },
                  )),
                  const SizedBox(height: 24),
                  
                  // Login Button
                  Obx(() => ElevatedButton(
                    onPressed: loginController.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              // Sync values from TextEditingControllers
                              loginController.setUsername(usernameController.text);
                              loginController.setPassword(passwordController.text);
                              loginController.login();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Get.theme.colorScheme.primary,
                      foregroundColor: Get.theme.colorScheme.onPrimary,
                    ),
                    child: loginController.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  )),
                  const SizedBox(height: 16),
                  
                  // Dummy Credentials Hint
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Dummy Credentials',
                          style: Get.theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Get.theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Username: admin\nPassword: password123',
                          textAlign: TextAlign.center,
                          style: Get.theme.textTheme.bodySmall?.copyWith(
                            color: Get.theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

