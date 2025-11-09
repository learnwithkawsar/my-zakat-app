import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/settings_controller.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../../common/utils/validators.dart';
import '../../../common/utils/error_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final controller = Get.put(SettingsController());
  final _formKey = GlobalKey<FormState>();
  final _goldPriceController = TextEditingController();
  final _silverPriceController = TextEditingController();
  final _zakatRateController = TextEditingController();
  final _nisabController = TextEditingController();
  final _currencyController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Load settings when controller is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  void _loadSettings() {
    final settings = controller.settings.value;
    if (settings != null) {
      _goldPriceController.text = settings.goldPricePerGram > 0
          ? settings.goldPricePerGram.toStringAsFixed(2)
          : '';
      _silverPriceController.text = settings.silverPricePerGram > 0
          ? settings.silverPricePerGram.toStringAsFixed(2)
          : '';
      _zakatRateController.text = settings.zakatRate.toStringAsFixed(2);
      _nisabController.text = settings.nisab > 0
          ? settings.nisab.toStringAsFixed(2)
          : '';
      _currencyController.text = settings.currency;
    }
  }

  @override
  void dispose() {
    _goldPriceController.dispose();
    _silverPriceController.dispose();
    _zakatRateController.dispose();
    _nisabController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (controller.settings.value == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Parse and validate values
      double? goldPrice;
      if (_goldPriceController.text.isNotEmpty) {
        goldPrice = double.tryParse(_goldPriceController.text);
        if (goldPrice == null || goldPrice < 0) {
          throw FormatException('Gold price must be a positive number');
        }
      }

      double? silverPrice;
      if (_silverPriceController.text.isNotEmpty) {
        silverPrice = double.tryParse(_silverPriceController.text);
        if (silverPrice == null || silverPrice < 0) {
          throw FormatException('Silver price must be a positive number');
        }
      }

      double zakatRate = double.tryParse(_zakatRateController.text) ?? 2.5;
      if (zakatRate < 0 || zakatRate > 100) {
        throw FormatException('Zakat rate must be between 0 and 100');
      }

      double nisab = 0.0;
      if (_nisabController.text.isNotEmpty) {
        nisab = double.tryParse(_nisabController.text) ?? 0.0;
        if (nisab < 0) {
          throw FormatException('Nisab must be a positive number');
        }
      }

      if (_currencyController.text.trim().isEmpty) {
        throw FormatException('Currency is required');
      }

      final updated = controller.settings.value!.copyWith(
        goldPricePerGram: goldPrice ?? 0.0,
        silverPricePerGram: silverPrice ?? 0.0,
        zakatRate: zakatRate,
        nisab: nisab,
        currency: _currencyController.text.trim(),
      );

      final success = await controller.updateSettings(updated);

      setState(() {
        _isSaving = false;
      });

      if (success) {
        ErrorHandler.showSuccess('Settings saved successfully');
      } else {
        ErrorHandler.handleError('Failed to save settings');
      }
    } catch (error) {
      setState(() {
        _isSaving = false;
      });
      ErrorHandler.handleError(error, context: 'Failed to save settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Obx(() {
        if (controller.settings.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final settings = controller.settings.value!;
        
        // Update controllers if they're empty or settings changed
        if (_goldPriceController.text.isEmpty || 
            _goldPriceController.text != (settings.goldPricePerGram > 0
                ? settings.goldPricePerGram.toStringAsFixed(2)
                : '')) {
          _goldPriceController.text = settings.goldPricePerGram > 0
              ? settings.goldPricePerGram.toStringAsFixed(2)
              : '';
        }
        if (_silverPriceController.text.isEmpty ||
            _silverPriceController.text != (settings.silverPricePerGram > 0
                ? settings.silverPricePerGram.toStringAsFixed(2)
                : '')) {
          _silverPriceController.text = settings.silverPricePerGram > 0
              ? settings.silverPricePerGram.toStringAsFixed(2)
              : '';
        }
        if (_zakatRateController.text.isEmpty ||
            _zakatRateController.text != settings.zakatRate.toStringAsFixed(2)) {
          _zakatRateController.text = settings.zakatRate.toStringAsFixed(2);
        }
        if (_nisabController.text.isEmpty ||
            _nisabController.text != (settings.nisab > 0
                ? settings.nisab.toStringAsFixed(2)
                : '')) {
          _nisabController.text = settings.nisab > 0
              ? settings.nisab.toStringAsFixed(2)
              : '';
        }
        if (_currencyController.text.isEmpty ||
            _currencyController.text != settings.currency) {
          _currencyController.text = settings.currency;
        }

        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
            // Currency Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Currency Settings',
                      style: Get.theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _currencyController,
                      labelText: 'Default Currency *',
                      hintText: 'e.g., BDT, USD, EUR',
                      prefixIcon: Icons.attach_money,
                      validator: (value) =>
                          Validators.validateRequired(value, fieldName: 'Currency'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Zakat Configuration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zakat Configuration',
                      style: Get.theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _zakatRateController,
                      labelText: 'Zakat Rate (%) *',
                      hintText: 'Default: 2.5',
                      prefixIcon: Icons.percent,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Zakat rate is required';
                        }
                        final rate = double.tryParse(value);
                        if (rate == null) {
                          return 'Please enter a valid number';
                        }
                        if (rate < 0 || rate > 100) {
                          return 'Rate must be between 0 and 100';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _nisabController,
                      labelText: 'Nisab Value',
                      hintText: 'Minimum zakatable amount (optional)',
                      prefixIcon: Icons.scale,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final nisab = double.tryParse(value);
                          if (nisab == null) {
                            return 'Please enter a valid number';
                          }
                          if (nisab < 0) {
                            return 'Nisab must be 0 or greater';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Gold & Silver Prices
            Card(
              color: Get.theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.stars,
                          color: Get.theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Gold & Silver Prices',
                          style: Get.theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set current market prices per gram for gold and silver. These prices will be used to automatically calculate asset values when you enter weight.',
                      style: Get.theme.textTheme.bodySmall?.copyWith(
                        color: Get.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _goldPriceController,
                      labelText: 'Gold Price per Gram *',
                      hintText: 'Enter current gold price',
                      prefixIcon: Icons.stars,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Gold price is required';
                        }
                        return Validators.validateAmount(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _silverPriceController,
                      labelText: 'Silver Price per Gram *',
                      hintText: 'Enter current silver price',
                      prefixIcon: Icons.star_border,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silver price is required';
                        }
                        return Validators.validateAmount(value);
                      },
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Get.theme.colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'These prices are used globally for all gold and silver assets. Update them regularly to reflect current market rates.',
                              style: Get.theme.textTheme.bodySmall?.copyWith(
                                color: Get.theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Settings'),
              ),
            ),
          ],
          ),
        );
      }),
    );
  }
}

