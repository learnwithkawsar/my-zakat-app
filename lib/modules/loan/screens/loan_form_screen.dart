import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/loan_controller.dart';
import '../../../models/loan_model.dart';
import '../../../models/borrower_model.dart';
import '../../../services/database_service.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../../common/utils/validators.dart';

class LoanFormScreen extends StatefulWidget {
  final String? borrowerId;
  final LoanModel? loan;

  const LoanFormScreen({super.key, this.borrowerId, this.loan});

  @override
  State<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends State<LoanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final controller = Get.put(LoanController());

  BorrowerModel? _selectedBorrower;
  DateTime _transactionDate = DateTime.now();
  DateTime? _dueDate;
  bool _includeInZakat = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.loan != null) {
      _selectedBorrower = DatabaseService.getBorrower(widget.loan!.borrowerId);
      _amountController.text = widget.loan!.amount.toString();
      _transactionDate = widget.loan!.transactionDate;
      _dueDate = widget.loan!.dueDate;
      _includeInZakat = widget.loan!.includeInZakat;
      _notesController.text = widget.loan!.notes ?? '';
    } else if (widget.borrowerId != null) {
      _selectedBorrower = DatabaseService.getBorrower(widget.borrowerId!);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isDueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDueDate ? (_dueDate ?? DateTime.now()) : _transactionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isDueDate) {
          _dueDate = picked;
        } else {
          _transactionDate = picked;
        }
      });
    }
  }

  Future<void> _saveLoan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBorrower == null) {
      Get.snackbar(
        'Error',
        'Please select a borrower',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final amount = double.parse(_amountController.text);

    final success = widget.loan == null
        ? await controller.addLoan(
            borrowerId: _selectedBorrower!.id,
            amount: amount,
            transactionDate: _transactionDate,
            dueDate: _dueDate,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            includeInZakat: _includeInZakat,
          )
        : await controller.updateLoan(
            widget.loan!.copyWith(
              borrowerId: _selectedBorrower!.id,
              amount: amount,
              transactionDate: _transactionDate,
              dueDate: _dueDate,
              notes: _notesController.text.isEmpty ? null : _notesController.text,
              includeInZakat: _includeInZakat,
            ),
          );

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        widget.loan == null
            ? 'Loan added successfully'
            : 'Loan updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loan == null ? 'Add Loan' : 'Edit Loan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Borrower Selection
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                  _selectedBorrower?.name ?? 'Select Borrower',
                  style: TextStyle(
                    color: _selectedBorrower == null
                        ? Get.theme.colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final borrowers = DatabaseService.getAllBorrowers();
                  if (borrowers.isEmpty) {
                    Get.snackbar(
                      'No Borrowers',
                      'Please add a borrower first',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  final selected = await Get.dialog<BorrowerModel>(
                    Dialog(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: borrowers.length,
                        itemBuilder: (context, index) {
                          final borrower = borrowers[index];
                          return ListTile(
                            title: Text(borrower.name),
                            onTap: () => Get.back(result: borrower),
                          );
                        },
                      ),
                    ),
                  );

                  if (selected != null) {
                    setState(() {
                      _selectedBorrower = selected;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _amountController,
              labelText: 'Amount *',
              hintText: 'Enter loan amount',
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) => Validators.validateAmount(value),
            ),
            const SizedBox(height: 16),
            // Transaction Date
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Transaction Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_transactionDate)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectDate(context, false),
              ),
            ),
            const SizedBox(height: 16),
            // Due Date (Optional)
            Card(
              child: ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Due Date (Optional)'),
                subtitle: Text(
                  _dueDate != null
                      ? DateFormat('MMM dd, yyyy').format(_dueDate!)
                      : 'Not set',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_dueDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _dueDate = null;
                          });
                        },
                      ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => _selectDate(context, true),
              ),
            ),
            const SizedBox(height: 16),
            // Include in Zakat
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.calculate),
                title: const Text('Include in Zakat Calculation'),
                subtitle: const Text('Include this loan in zakat calculations'),
                value: _includeInZakat,
                onChanged: (value) {
                  setState(() {
                    _includeInZakat = value;
                  });
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
                onPressed: _isSaving ? null : _saveLoan,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.loan == null ? 'Add Loan' : 'Update Loan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

