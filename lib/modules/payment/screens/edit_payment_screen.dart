import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/payment_controller.dart';
import '../../../models/payment_model.dart';
import '../../../models/loan_model.dart';
import '../../../models/borrower_model.dart';
import '../../../services/database_service.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../../common/utils/validators.dart';

class EditPaymentScreen extends StatefulWidget {
  final PaymentModel payment;

  const EditPaymentScreen({super.key, required this.payment});

  @override
  State<EditPaymentScreen> createState() => _EditPaymentScreenState();
}

class _EditPaymentScreenState extends State<EditPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final controller = Get.find<PaymentController>();

  LoanModel? _loan;
  BorrowerModel? _borrower;
  List<LoanModel> _borrowerLoans = [];
  DateTime _paymentDate = DateTime.now();
  String? _paymentType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _borrower = DatabaseService.getBorrower(widget.payment.borrowerId);
    if (widget.payment.isForSpecificLoan) {
      _loan = DatabaseService.getLoan(widget.payment.loanId!);
    } else {
      _borrowerLoans = DatabaseService.getLoansByBorrower(widget.payment.borrowerId);
    }
    _amountController.text = widget.payment.amount.toString();
    _paymentDate = widget.payment.date;
    _paymentType = widget.payment.paymentType;
    _notesController.text = widget.payment.notes ?? '';
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

    final amount = double.parse(_amountController.text);
    
    if (widget.payment.isForSpecificLoan) {
      if (_loan == null) return;
      
      // Calculate outstanding balance excluding this payment
      final existingPayments = DatabaseService.getPaymentsByLoan(widget.payment.loanId!);
      final otherPaymentsTotal = existingPayments
          .where((p) => p.id != widget.payment.id)
          .fold<double>(0.0, (sum, p) => sum + p.amount);
      
      final loanOutstandingWithoutBorrower = 
          DatabaseService.calculateLoanOutstandingWithoutBorrowerPayments(widget.payment.loanId!);
      final maxAllowed = loanOutstandingWithoutBorrower + widget.payment.amount - otherPaymentsTotal;

      if (amount > maxAllowed) {
        Get.snackbar(
          'Error',
          'Payment amount cannot exceed outstanding balance of ${NumberFormat('#,##0.00').format(maxAllowed)}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    } else {
      // Borrower-level payment validation
      final totalOutstanding = DatabaseService.calculateBorrowerOutstanding(widget.payment.borrowerId);
      if (amount > totalOutstanding) {
        Get.snackbar(
          'Error',
          'Payment amount cannot exceed total outstanding balance of ${NumberFormat('#,##0.00').format(totalOutstanding)}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    final updatedPayment = widget.payment.copyWith(
      amount: amount,
      date: _paymentDate,
      paymentType: _paymentType,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    final success = await controller.updatePayment(updatedPayment);

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Get.back(result: true); // Return true to indicate refresh needed
      Get.snackbar(
        'Success',
        'Payment updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
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

    double maxAllowed = 0.0;
    if (widget.payment.isForSpecificLoan && _loan != null) {
      final existingPayments = DatabaseService.getPaymentsByLoan(widget.payment.loanId!);
      final otherPaymentsTotal = existingPayments
          .where((p) => p.id != widget.payment.id)
          .fold<double>(0.0, (sum, p) => sum + p.amount);
      final loanOutstandingWithoutBorrower = 
          DatabaseService.calculateLoanOutstandingWithoutBorrowerPayments(widget.payment.loanId!);
      maxAllowed = loanOutstandingWithoutBorrower + widget.payment.amount - otherPaymentsTotal;
    } else {
      maxAllowed = DatabaseService.calculateBorrowerOutstanding(widget.payment.borrowerId);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Payment'),
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
                      widget.payment.isForSpecificLoan
                          ? 'Max Allowed Amount'
                          : 'Total Outstanding',
                      style: Get.theme.textTheme.titleSmall?.copyWith(
                        color: Get.theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat('#,##0.00').format(maxAllowed),
                      style: Get.theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Get.theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    if (widget.payment.isForSpecificLoan && _loan != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Loan Amount: ${NumberFormat('#,##0.00').format(_loan!.amount)}',
                        style: Get.theme.textTheme.bodySmall?.copyWith(
                          color: Get.theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      Text(
                        'This payment applies to all ${_borrowerLoans.length} loan(s) proportionally',
                        style: Get.theme.textTheme.bodySmall?.copyWith(
                          color: Get.theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
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
                    : const Text('Update Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

