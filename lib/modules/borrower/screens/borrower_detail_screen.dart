import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/borrower_controller.dart';
import '../../../models/borrower_model.dart';
import '../../../models/loan_model.dart';
import '../../../services/database_service.dart';
import '../../../common/widgets/empty_state.dart';
import 'package:intl/intl.dart';
import '../../../common/utils/date_formatter.dart';
import '../../loan/screens/loan_form_screen.dart';
import '../../loan/screens/loan_detail_screen.dart';
import '../../payment/screens/borrower_payments_screen.dart';
import '../../payment/screens/add_borrower_payment_screen.dart';
import 'borrower_form_screen.dart';

class BorrowerDetailScreen extends StatelessWidget {
  final String borrowerId;

  const BorrowerDetailScreen({super.key, required this.borrowerId});

  @override
  Widget build(BuildContext context) {
    final borrowerController = Get.find<BorrowerController>();
    
    // Use Obx to make the screen reactive to borrower data changes
    return Obx(() {
      final borrower = borrowerController.getBorrowerById(borrowerId);
      final settings = DatabaseService.getSettings();

    if (borrower == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Borrower Details')),
        body: const Center(child: Text('Borrower not found')),
      );
    }

    final loans = DatabaseService.getLoansByBorrower(borrowerId);
    final outstanding = borrowerController.getBorrowerOutstanding(borrowerId);

    return Scaffold(
      appBar: AppBar(
        title: Text(borrower.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.to(() => BorrowerFormScreen(borrower: borrower));
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
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
                  _showDeleteDialog(context, borrower, borrowerController);
                },
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await borrowerController.loadBorrowers();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          // Borrower Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Get.theme.colorScheme.primaryContainer,
                        child: Text(
                          borrower.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Get.theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              borrower.name,
                              style: Get.theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (borrower.contactInfo != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                borrower.contactInfo!,
                                style: Get.theme.textTheme.bodyMedium,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (borrower.address != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: Get.theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            borrower.address!,
                            style: Get.theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (borrower.notes != null && borrower.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Notes',
                      style: Get.theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      borrower.notes!,
                      style: Get.theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Outstanding Balance Card
          Card(
            color: outstanding > 0
                ? Get.theme.colorScheme.errorContainer
                : Get.theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Outstanding Balance',
                        style: Get.theme.textTheme.titleSmall?.copyWith(
                          color: outstanding > 0
                              ? Get.theme.colorScheme.onErrorContainer
                              : Get.theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                  Icon(
                    outstanding > 0 ? Icons.warning : Icons.check_circle,
                    size: 40,
                    color: outstanding > 0
                        ? Get.theme.colorScheme.onErrorContainer
                        : Get.theme.colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Payment Actions
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () async {
                      final result = await Get.to(() => AddBorrowerPaymentScreen(borrowerId: borrowerId));
                      if (result == true) {
                        // Refresh the screen by reloading borrower data
                        await borrowerController.loadBorrowers();
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.payment,
                            color: Get.theme.colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Add Payment',
                              style: Get.theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Get.theme.colorScheme.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      Get.to(() => BorrowerPaymentsScreen(borrowerId: borrowerId));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            color: Get.theme.colorScheme.secondary,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'View Payments',
                              style: Get.theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Get.theme.colorScheme.secondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Loans Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loans (${loans.length})',
                style: Get.theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final result = await Get.to(() => LoanFormScreen(borrowerId: borrowerId));
                  if (result == true) {
                    // Refresh the screen by reloading borrower data
                    await borrowerController.loadBorrowers();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Loan'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (loans.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Loans',
                  message: 'This borrower has no loans yet',
                  actionLabel: 'Add Loan',
                  onAction: () {
                    Get.to(() => LoanFormScreen(borrowerId: borrowerId));
                  },
                ),
              ),
            )
          else
            ...loans.map((loan) {
              final loanOutstanding = DatabaseService.calculateLoanOutstanding(loan.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Get.theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: Get.theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    NumberFormat('#,##0.00').format(loan.amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${DateFormatter.formatDisplay(loan.transactionDate)}'),
                      if (loan.dueDate != null)
                        Text(
                          'Due: ${DateFormatter.formatDisplay(loan.dueDate!)}',
                          style: TextStyle(
                            color: DateFormatter.isOverdue(loan.dueDate)
                                ? Get.theme.colorScheme.error
                                : null,
                          ),
                        ),
                      Text(
                        'Outstanding: ${NumberFormat('#,##0.00').format(loanOutstanding)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: loanOutstanding > 0
                              ? Get.theme.colorScheme.error
                              : Get.theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  trailing: !loan.includeInZakat
                      ? const Icon(
                          Icons.block,
                          size: 20,
                          color: Colors.orange,
                        )
                      : const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                  onTap: () {
                    Get.to(() => LoanDetailScreen(loanId: loan.id));
                  },
                ),
              );
            }),
        ],
        ),
      ),
    );
    });
  }

  void _showDeleteDialog(
    BuildContext context,
    BorrowerModel borrower,
    BorrowerController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Borrower'),
        content: Text(
          'Are you sure you want to delete ${borrower.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deleteBorrower(borrower.id);
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

