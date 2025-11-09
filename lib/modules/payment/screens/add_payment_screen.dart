import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/payment_controller.dart';
import '../../../models/loan_model.dart';
import '../../../services/database_service.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../../common/utils/validators.dart';
import 'package:intl/intl.dart';

class AddPaymentScreen extends StatefulWidget {
  final String loanId;

  const AddPaymentScreen({super.key, required this.loanId});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final controller = Get.put(PaymentController());

  LoanModel? _loan;
  DateTime _paymentDate = DateTime.now();
  String? _paymentType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loan = DatabaseService.getLoan(widget.loanId);
    if (_loan == null) {
      Get.back();
      Get.snackbar(
        'Error',
        'Loan not found',
        snackPosition: SnackPosition.BOTTOM,
      );
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

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_loan == null) return;

    final amount = double.parse(_amountController.text);
    final outstanding = DatabaseService.calculateLoanOutstanding(widget.loanId);

    if (amount > outstanding) {
      Get.snackbar(
        'Error',
        'Payment amount cannot exceed outstanding balance of ${NumberFormat('#,##0.00').format(outstanding)}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success = await controller.addPayment(
      loanId: widget.loanId,
      amount: amount,
      date: _paymentDate,
      paymentType: _paymentType,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        'Payment added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loan == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final outstanding = DatabaseService.calculateLoanOutstanding(widget.loanId);
    final settings = DatabaseService.getSettings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Loan Info Card
            Card(
              color: Get.theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Outstanding Balance',
                      style: Get.theme.textTheme.titleSmall?.copyWith(
                        color: Get.theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat('#,##0.00').format(outstanding),
                      style: Get.theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Get.theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _amountController,
              labelText: 'Payment Amount *',
              hintText: 'Enter payment amount',
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) => Validators.validateAmount(value),
            ),
            const SizedBox(height: 16),
            // Payment Date
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Payment Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_paymentDate)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 16),
            // Payment Type (Optional)
            Card(
              child: ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Payment Type (Optional)'),
                subtitle: Text(_paymentType ?? 'Not specified'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Get.bottomSheet(
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('Cash'),
                            onTap: () {
                              setState(() {
                                _paymentType = 'Cash';
                              });
                              Get.back();
                            },
                          ),
                          ListTile(
                            title: const Text('Bank Transfer'),
                            onTap: () {
                              setState(() {
                                _paymentType = 'Bank Transfer';
                              });
                              Get.back();
                            },
                          ),
                          ListTile(
                            title: const Text('Check'),
                            onTap: () {
                              setState(() {
                                _paymentType = 'Check';
                              });
                              Get.back();
                            },
                          ),
                          ListTile(
                            title: const Text('Other'),
                            onTap: () {
                              setState(() {
                                _paymentType = 'Other';
                              });
                              Get.back();
                            },
                          ),
                          ListTile(
                            title: const Text('Clear'),
                            onTap: () {
                              setState(() {
                                _paymentType = null;
                              });
                              Get.back();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
                onPressed: _isSaving ? null : _savePayment,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

