import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ZakatCalculatorScreen extends StatelessWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calculate,
                size: 80,
                color: Get.theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Zakat Calculator',
                style: Get.theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Calculate your Zakat easily based on your assets',
                textAlign: TextAlign.center,
                style: Get.theme.textTheme.bodyLarge?.copyWith(
                  color: Get.theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Get.snackbar(
                    'Coming Soon',
                    'Zakat calculator will be available soon',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Start Calculation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

