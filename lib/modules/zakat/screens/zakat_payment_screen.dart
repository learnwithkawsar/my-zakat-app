import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../controllers/zakat_controller.dart';
import '../../../models/beneficiary_model.dart';
import '../../../services/database_service.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../../common/utils/validators.dart';
import '../../../common/utils/error_handler.dart';
import '../../../common/utils/date_formatter.dart';

class ZakatPaymentScreen extends StatefulWidget {
  final String zakatRecordId;
  final String zakatYear;

  const ZakatPaymentScreen({
    super.key,
    required this.zakatRecordId,
    required this.zakatYear,
  });

  @override
  State<ZakatPaymentScreen> createState() => _ZakatPaymentScreenState();
}

class _ZakatPaymentScreenState extends State<ZakatPaymentScreen> {
  final controller = Get.find<ZakatController>();
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  BeneficiaryModel? _selectedBeneficiary;
  DateTime _paymentDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final record = controller.zakatRecords.firstWhereOrNull(
      (r) => r.id == widget.zakatRecordId,
    );
    if (record != null && record.balance > 0) {
      _amountController.text = record.balance.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _paymentDate = picked;
      });
    }
  }

  Future<void> _selectBeneficiary() async {
    final beneficiaries = controller.getAllBeneficiaries();
    
    if (beneficiaries.isEmpty) {
      ErrorHandler.showWarning(
        'No beneficiaries found. Please add beneficiaries first.',
      );
      return;
    }

    await Get.bottomSheet(
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
                'Select Beneficiary',
                style: Get.theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            ...beneficiaries.map((beneficiary) {
              final isSelected = _selectedBeneficiary?.id == beneficiary.id;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSelected
                      ? Get.theme.colorScheme.primary
                      : Get.theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.person,
                    color: isSelected
                        ? Get.theme.colorScheme.onPrimary
                        : Get.theme.colorScheme.onSurface,
                  ),
                ),
                title: Text(
                  beneficiary.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Get.theme.colorScheme.primary
                        : Get.theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: beneficiary.contactInfo != null
                    ? Text(beneficiary.contactInfo!)
                    : null,
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: Get.theme.colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    _selectedBeneficiary = beneficiary;
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
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBeneficiary == null) {
      ErrorHandler.showWarning('Please select a beneficiary');
      return;
    }

    final record = controller.zakatRecords.firstWhereOrNull(
      (r) => r.id == widget.zakatRecordId,
    );

    if (record == null) {
      ErrorHandler.handleError('Zakat record not found');
      return;
    }

    final amount = double.parse(_amountController.text);

    if (amount <= 0) {
      ErrorHandler.showWarning('Amount must be greater than 0');
      return;
    }

    if (amount > record.balance) {
      ErrorHandler.showWarning(
        'Amount cannot exceed balance of ${NumberFormat('#,##0.00').format(record.balance)}',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success = await controller.addZakatPayment(
      zakatRecordId: widget.zakatRecordId,
      beneficiaryId: _selectedBeneficiary!.id,
      amount: amount,
      paymentDate: _paymentDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Get.back(result: true); // Return true to indicate refresh needed
      // Show success message
      Get.snackbar(
        'Success',
        'Zakat payment recorded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = controller.zakatRecords.firstWhereOrNull(
      (r) => r.id == widget.zakatRecordId,
    );
    final settings = DatabaseService.getSettings();

    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pay Zakat')),
        body: const Center(child: Text('Zakat record not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Pay Zakat - ${widget.zakatYear}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Balance Info Card
            Card(
              color: Get.theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zakat Balance',
                      style: Get.theme.textTheme.titleMedium?.copyWith(
                        color: Get.theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${NumberFormat('#,##0.00').format(record.balance)} ${settings.currency}',
                      style: Get.theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Get.theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Zakat Due: ${NumberFormat('#,##0.00').format(record.zakatDue)} ${settings.currency}',
                      style: Get.theme.textTheme.bodySmall?.copyWith(
                        color: Get.theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'Amount Paid: ${NumberFormat('#,##0.00').format(record.amountPaid)} ${settings.currency}',
                      style: Get.theme.textTheme.bodySmall?.copyWith(
                        color: Get.theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Beneficiary Selection
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Beneficiary *'),
                subtitle: Text(
                  _selectedBeneficiary?.name ?? 'Select beneficiary',
                  style: TextStyle(
                    color: _selectedBeneficiary == null
                        ? Get.theme.colorScheme.onSurfaceVariant
                        : Get.theme.colorScheme.onSurface,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectBeneficiary,
              ),
            ),
            const SizedBox(height: 16),
            // Amount Input
            CustomTextField(
              controller: _amountController,
              labelText: 'Payment Amount *',
              hintText: 'Enter amount',
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Amount is required';
                }
                final amount = double.tryParse(value);
                if (amount == null) {
                  return 'Please enter a valid number';
                }
                if (amount <= 0) {
                  return 'Amount must be greater than 0';
                }
                if (amount > record.balance) {
                  return 'Amount cannot exceed balance';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Payment Date
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Payment Date *'),
                subtitle: Text(DateFormatter.formatDisplay(_paymentDate)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 16),
            // Notes
            CustomTextField(
              controller: _notesController,
              labelText: 'Notes',
              hintText: 'Additional notes (optional)',
              prefixIcon: Icons.note,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _savePayment,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Record Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

