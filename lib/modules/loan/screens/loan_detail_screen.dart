import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/loan_controller.dart';
import '../../../models/loan_model.dart';
import '../../../models/borrower_model.dart';
import '../../../services/database_service.dart';
import 'package:intl/intl.dart';
import '../../../common/utils/date_formatter.dart';
import 'loan_form_screen.dart';

class LoanDetailScreen extends StatelessWidget {
  final String loanId;

  const LoanDetailScreen({super.key, required this.loanId});

  @override
  Widget build(BuildContext context) {
    final loanController = Get.put(LoanController());
    final loan = loanController.getLoanById(loanId);
    final settings = DatabaseService.getSettings();

    if (loan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loan Details')),
        body: const Center(child: Text('Loan not found')),
      );
    }

    final borrower = DatabaseService.getBorrower(loan.borrowerId);
    final outstanding = loanController.getLoanOutstanding(loanId);
    
    // Calculate total paid (loan-specific payments only)
    final loanPayments = DatabaseService.getPaymentsByLoan(loanId);
    final totalPaid = loanPayments.fold<double>(
      0.0,
      (sum, payment) => sum + payment.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(borrower?.name ?? 'Loan Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.to(() => LoanFormScreen(loan: loan));
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      loan.includeInZakat
                          ? Icons.block
                          : Icons.check_circle,
                      color: loan.includeInZakat
                          ? Colors.orange
                          : Get.theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(loan.includeInZakat
                        ? 'Exclude from Zakat'
                        : 'Include in Zakat'),
                  ],
                ),
                onTap: () async {
                  await Future.delayed(const Duration(milliseconds: 100));
                  await loanController.toggleIncludeInZakat(loanId);
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
                onTap: () async {
                  await Future.delayed(const Duration(milliseconds: 100));
                  _showDeleteDialog(context, loan, loanController);
                },
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Loan Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                      'Loan Amount',
                      style: Get.theme.textTheme.titleMedium,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    NumberFormat('#,##0.00').format(loan.amount),
                    style: Get.theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Borrower',
                    borrower?.name ?? 'Unknown',
                    Icons.person,
                  ),
                  _buildInfoRow(
                    'Transaction Date',
                    DateFormatter.formatDisplay(loan.transactionDate),
                    Icons.calendar_today,
                  ),
                  if (loan.dueDate != null)
                    _buildInfoRow(
                      'Due Date',
                      DateFormatter.formatDisplay(loan.dueDate!),
                      Icons.event,
                      isOverdue: DateFormatter.isOverdue(loan.dueDate),
                    ),
                  if (loan.notes != null && loan.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Notes',
                      style: Get.theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loan.notes!,
                      style: Get.theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Payment Summary Card
          Card(
            color: outstanding > 0
                ? Get.theme.colorScheme.errorContainer
                : Get.theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Paid',
                        style: Get.theme.textTheme.titleSmall?.copyWith(
                          color: outstanding > 0
                              ? Get.theme.colorScheme.onErrorContainer
                              : Get.theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        NumberFormat('#,##0.00').format(totalPaid),
                        style: Get.theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: outstanding > 0
                              ? Get.theme.colorScheme.onErrorContainer
                              : Get.theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Outstanding Balance',
                        style: Get.theme.textTheme.titleSmall?.copyWith(
                          color: outstanding > 0
                              ? Get.theme.colorScheme.onErrorContainer
                              : Get.theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        NumberFormat('#,##0.00').format(outstanding),
                        style: Get.theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: outstanding > 0
                              ? Get.theme.colorScheme.onErrorContainer
                              : Get.theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {bool isOverdue = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isOverdue
                ? Get.theme.colorScheme.error
                : Get.theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Get.theme.textTheme.bodySmall?.copyWith(
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: Get.theme.textTheme.bodyMedium?.copyWith(
                    color: isOverdue
                        ? Get.theme.colorScheme.error
                        : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    LoanModel loan,
    LoanController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Loan'),
        content: Text(
          'Are you sure you want to delete this loan? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deleteLoan(loan.id);
              if (success) {
                Get.back(); // Go back to list
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

