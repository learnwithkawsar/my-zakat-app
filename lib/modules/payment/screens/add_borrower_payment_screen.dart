import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/payment_controller.dart';
import '../../../models/borrower_model.dart';
import '../../../models/loan_model.dart';
import '../../../services/database_service.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../../common/utils/validators.dart';
import '../../borrower/controllers/borrower_controller.dart';

class AddBorrowerPaymentScreen extends StatefulWidget {
  final String borrowerId;

  const AddBorrowerPaymentScreen({super.key, required this.borrowerId});

  @override
  State<AddBorrowerPaymentScreen> createState() => _AddBorrowerPaymentScreenState();
}

class _AddBorrowerPaymentScreenState extends State<AddBorrowerPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final controller = Get.put(PaymentController());

  BorrowerModel? _borrower;
  List<LoanModel> _loans = [];
  DateTime _paymentDate = DateTime.now();
  String? _paymentType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _borrower = DatabaseService.getBorrower(widget.borrowerId);
    _loans = DatabaseService.getLoansByBorrower(widget.borrowerId);
    if (_borrower == null) {
      Get.back();
      Get.snackbar(
        'Error',
        'Borrower not found',
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

    if (_borrower == null) return;

    final amount = double.parse(_amountController.text);
    final totalOutstanding = DatabaseService.calculateBorrowerOutstanding(widget.borrowerId);

    if (amount > totalOutstanding) {
      Get.snackbar(
        'Error',
        'Payment amount cannot exceed total outstanding balance of ${NumberFormat('#,##0.00').format(totalOutstanding)}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success = await controller.addBorrowerPayment(
      borrowerId: widget.borrowerId,
      amount: amount,
      date: _paymentDate,
      paymentType: _paymentType,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    setState(() {
      _isSaving = false;
    });

    if (success) {
      // Refresh borrower controller to update outstanding balance
      try {
        final borrowerController = Get.find<BorrowerController>();
        await borrowerController.loadBorrowers();
      } catch (e) {
        // Controller might not be initialized, that's okay
      }
      
      Get.back(result: true); // Return true to indicate refresh needed
      Get.snackbar(
        'Success',
        'Payment added successfully. It will be allocated proportionally across all loans.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_borrower == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalOutstanding = DatabaseService.calculateBorrowerOutstanding(widget.borrowerId);
    final totalLoanAmount = _loans.fold<double>(0.0, (sum, loan) => sum + loan.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Payment - ${_borrower!.name}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info Card
            Card(
              color: Get.theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Borrower-Level Payment',
                      style: Get.theme.textTheme.titleMedium?.copyWith(
                        color: Get.theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This payment will be allocated proportionally across all ${_loans.length} loan(s) based on outstanding balances.',
                      style: Get.theme.textTheme.bodySmall?.copyWith(
                        color: Get.theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Outstanding',
                          style: Get.theme.textTheme.titleSmall?.copyWith(
                            color: Get.theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          NumberFormat('#,##0.00').format(totalOutstanding),
                          style: Get.theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Get.theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Loans Summary
            if (_loans.isNotEmpty) ...[
              Text(
                'Loans Summary',
                style: Get.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._loans.map((loan) {
                final outstanding = DatabaseService.calculateLoanOutstanding(loan.id);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      'Loan: ${NumberFormat('#,##0.00').format(loan.amount)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Outstanding: ${NumberFormat('#,##0.00').format(outstanding)}',
                      style: TextStyle(
                        color: outstanding > 0
                            ? Get.theme.colorScheme.error
                            : Get.theme.colorScheme.primary,
                      ),
                    ),
                    trailing: Text(
                      '${((outstanding / totalOutstanding) * 100).toStringAsFixed(1)}%',
                      style: Get.theme.textTheme.bodySmall,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
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
                              'Select Payment Type',
                              style: Get.theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.money),
                            title: const Text('Cash'),
                            trailing: _paymentType == 'Cash'
                                ? Icon(Icons.check_circle, color: Get.theme.colorScheme.primary)
                                : null,
                            onTap: () {
                              setState(() {
                                _paymentType = 'Cash';
                              });
                              Get.back();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.account_balance),
                            title: const Text('Bank Transfer'),
                            trailing: _paymentType == 'Bank Transfer'
                                ? Icon(Icons.check_circle, color: Get.theme.colorScheme.primary)
                                : null,
                            onTap: () {
                              setState(() {
                                _paymentType = 'Bank Transfer';
                              });
                              Get.back();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.description),
                            title: const Text('Check'),
                            trailing: _paymentType == 'Check'
                                ? Icon(Icons.check_circle, color: Get.theme.colorScheme.primary)
                                : null,
                            onTap: () {
                              setState(() {
                                _paymentType = 'Check';
                              });
                              Get.back();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.more_horiz),
                            title: const Text('Other'),
                            trailing: _paymentType == 'Other'
                                ? Icon(Icons.check_circle, color: Get.theme.colorScheme.primary)
                                : null,
                            onTap: () {
                              setState(() {
                                _paymentType = 'Other';
                              });
                              Get.back();
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading: Icon(Icons.clear, color: Get.theme.colorScheme.error),
                            title: Text(
                              'Clear',
                              style: TextStyle(color: Get.theme.colorScheme.error),
                            ),
                            onTap: () {
                              setState(() {
                                _paymentType = null;
                              });
                              Get.back();
                            },
                          ),
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

