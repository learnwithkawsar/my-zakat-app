import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/asset_controller.dart';
import '../../../models/asset_model.dart';
import '../../../services/database_service.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../../common/utils/validators.dart';
import '../../../common/utils/date_formatter.dart';
import '../../../common/utils/error_handler.dart';

class AssetFormScreen extends StatefulWidget {
  final AssetModel? asset;

  const AssetFormScreen({super.key, this.asset});

  @override
  State<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends State<AssetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  final controller = Get.put(AssetController());

  AssetType _selectedType = AssetType.cash;
  DateTime _valuationDate = DateTime.now();
  bool _isSaving = false;
  bool _useWeightCalculation = false;

  @override
  void initState() {
    super.initState();
    if (widget.asset != null) {
      _nameController.text = widget.asset!.name;
      _selectedType = widget.asset!.type;
      _valueController.text = widget.asset!.value.toString();
      _valuationDate = widget.asset!.valuationDate;
      _notesController.text = widget.asset!.notes ?? '';
      if (widget.asset!.weightInGrams != null) {
        _weightController.text = widget.asset!.weightInGrams.toString();
        _useWeightCalculation = true;
      }
    } else {
      _selectedType = AssetType.cash;
    }
    _checkIfWeightBased();
  }

  void _checkIfWeightBased() {
    _useWeightCalculation = _selectedType == AssetType.gold ||
        _selectedType == AssetType.silver;
    if (_useWeightCalculation && _weightController.text.isNotEmpty) {
      _calculateValueFromWeight();
    }
  }

  void _calculateValueFromWeight() {
    if (_weightController.text.isEmpty) return;

    try {
      final weight = double.parse(_weightController.text);
      final settings = DatabaseService.getSettings();
      double pricePerGram = 0.0;

      if (_selectedType == AssetType.gold) {
        pricePerGram = settings.goldPricePerGram;
      } else if (_selectedType == AssetType.silver) {
        pricePerGram = settings.silverPricePerGram;
      }

      if (pricePerGram > 0) {
        final calculatedValue = weight * pricePerGram;
        setState(() {
          _valueController.text = calculatedValue.toStringAsFixed(2);
        });
      } else {
        Get.snackbar(
          'Warning',
          'Please set ${_selectedType == AssetType.gold ? "gold" : "silver"} price per gram in settings',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Invalid weight input
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _valuationDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _valuationDate = picked;
      });
    }
  }

  Future<void> _saveAsset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final settings = DatabaseService.getSettings();
      
      // Validate and parse value
      double value;
      try {
        value = double.parse(_valueController.text);
        if (value <= 0) {
          throw FormatException('Value must be greater than 0');
        }
      } catch (e) {
        setState(() {
          _isSaving = false;
        });
        ErrorHandler.handleError(
          e,
          context: 'Invalid asset value',
        );
        return;
      }

      // Parse weight if provided
      double? weight;
      if (_weightController.text.isNotEmpty) {
        try {
          weight = double.tryParse(_weightController.text);
          if (weight == null || weight <= 0) {
            throw FormatException('Weight must be a positive number');
          }
        } catch (e) {
          setState(() {
            _isSaving = false;
          });
          ErrorHandler.handleError(
            e,
            context: 'Invalid weight',
          );
          return;
        }
      }

      // Validate weight for gold/silver
      if (_useWeightCalculation && (weight == null || weight <= 0)) {
        setState(() {
          _isSaving = false;
        });
        ErrorHandler.showWarning(
          'Please enter a valid weight for ${_selectedType == AssetType.gold ? "gold" : "silver"}',
        );
        return;
      }

      final asset = AssetModel(
        id: widget.asset?.id ?? DatabaseService.generateId(),
        name: _nameController.text.trim(),
        type: _selectedType,
        value: value,
        currency: settings.currency,
        valuationDate: _valuationDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        weightInGrams: weight,
      );

      final success = widget.asset == null
          ? await controller.addAsset(asset)
          : await controller.updateAsset(asset);

      setState(() {
        _isSaving = false;
      });

      if (success) {
        Get.back();
        ErrorHandler.showSuccess(
          widget.asset == null
              ? 'Asset added successfully'
              : 'Asset updated successfully',
        );
      } else {
        // If controller returns false, show generic error
        ErrorHandler.handleError(
          'Operation failed',
          context: widget.asset == null ? 'Failed to add asset' : 'Failed to update asset',
        );
      }
    } catch (error) {
      setState(() {
        _isSaving = false;
      });
      ErrorHandler.handleError(
        error,
        context: widget.asset == null ? 'Failed to add asset' : 'Failed to update asset',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = DatabaseService.getSettings();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.asset == null ? 'Add Asset' : 'Edit Asset'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _nameController,
              labelText: 'Asset Name *',
              hintText: 'Enter asset name',
              prefixIcon: Icons.label,
              validator: (value) => Validators.validateRequired(value, fieldName: 'Asset name'),
            ),
            const SizedBox(height: 16),
            // Asset Type
            Card(
              child: ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Asset Type *'),
                subtitle: Text(_getAssetTypeLabel(_selectedType)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Get.bottomSheet(
                    Container(
                      decoration: BoxDecoration(
                        color: Get.theme.scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Get.theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'Select Asset Type',
                              style: Get.theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Divider(),
                          ...AssetType.values.map((type) {
                            final isSelected = _selectedType == type;
                            return ListTile(
                              leading: Icon(
                                _getAssetTypeIcon(type),
                                color: isSelected
                                    ? Get.theme.colorScheme.primary
                                    : Get.theme.colorScheme.onSurface,
                              ),
                              title: Text(
                                _getAssetTypeLabel(type),
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? Get.theme.colorScheme.primary
                                      : Get.theme.colorScheme.onSurface,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: Get.theme.colorScheme.primary,
                                    )
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedType = type;
                                  _checkIfWeightBased();
                                  if (_useWeightCalculation) {
                                    _weightController.clear();
                                    _valueController.clear();
                                  }
                                });
                                Get.back();
                              },
                            );
                          }),
                          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                        ],
                      ),
                    ),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Weight input for gold/silver
            if (_useWeightCalculation) ...[
              Card(
                color: Get.theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weight-based Calculation',
                        style: Get.theme.textTheme.titleSmall?.copyWith(
                          color: Get.theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current ${_selectedType == AssetType.gold ? "gold" : "silver"} price: ${NumberFormat('#,##0.00').format(_selectedType == AssetType.gold ? settings.goldPricePerGram : settings.silverPricePerGram)} ${settings.currency}/gram',
                        style: Get.theme.textTheme.bodySmall?.copyWith(
                          color: Get.theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      if ((_selectedType == AssetType.gold &&
                              settings.goldPricePerGram == 0) ||
                          (_selectedType == AssetType.silver &&
                              settings.silverPricePerGram == 0))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '⚠️ Please set price in settings first',
                            style: TextStyle(
                              color: Get.theme.colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _weightController,
                labelText: 'Weight (grams) *',
                hintText: 'Enter weight in grams',
                prefixIcon: Icons.scale,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (_useWeightCalculation) {
                    return Validators.validateAmount(value);
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_useWeightCalculation && value.isNotEmpty) {
                    _calculateValueFromWeight();
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
            CustomTextField(
              controller: _valueController,
              labelText: _useWeightCalculation
                  ? 'Calculated Value (read-only)'
                  : 'Asset Value *',
              hintText: 'Enter asset value',
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              enabled: !_useWeightCalculation,
              validator: (value) => Validators.validateAmount(value),
            ),
            const SizedBox(height: 16),
            // Valuation Date
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Valuation Date *'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_valuationDate)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _notesController,
              labelText: 'Notes',
              hintText: 'Additional notes (optional)',
              prefixIcon: Icons.note,
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAsset,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.asset == null ? 'Add Asset' : 'Update Asset'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAssetTypeLabel(AssetType type) {
    switch (type) {
      case AssetType.cash:
        return 'Cash';
      case AssetType.bank:
        return 'Bank';
      case AssetType.gold:
        return 'Gold';
      case AssetType.silver:
        return 'Silver';
      case AssetType.investment:
        return 'Investment';
      case AssetType.property:
        return 'Property';
      case AssetType.business:
        return 'Business';
      case AssetType.other:
        return 'Other';
    }
  }

  IconData _getAssetTypeIcon(AssetType type) {
    switch (type) {
      case AssetType.cash:
        return Icons.money;
      case AssetType.bank:
        return Icons.account_balance;
      case AssetType.gold:
        return Icons.stars;
      case AssetType.silver:
        return Icons.star_border;
      case AssetType.investment:
        return Icons.trending_up;
      case AssetType.property:
        return Icons.home;
      case AssetType.business:
        return Icons.business;
      case AssetType.other:
        return Icons.category;
    }
  }
}

