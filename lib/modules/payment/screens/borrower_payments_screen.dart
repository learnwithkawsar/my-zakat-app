import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/payment_controller.dart';
import '../../../models/borrower_model.dart';
import '../../../models/payment_model.dart';
import '../../../models/loan_model.dart';
import '../../../services/database_service.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/utils/date_formatter.dart';
import 'edit_payment_screen.dart';
import '../../loan/screens/loan_detail_screen.dart';
import '../../borrower/controllers/borrower_controller.dart';

class BorrowerPaymentsScreen extends StatelessWidget {
  final String borrowerId;

  const BorrowerPaymentsScreen({super.key, required this.borrowerId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentController());
    final borrower = DatabaseService.getBorrower(borrowerId);

    if (borrower == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment History')),
        body: const Center(child: Text('Borrower not found')),
      );
    }

    // Load payments
    controller.loadPaymentsByBorrower(borrowerId);

    return Scaffold(
      appBar: AppBar(
        title: Text('${borrower.name} - Payments'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.payments.isEmpty) {
          return EmptyState(
            icon: Icons.payment_outlined,
            title: 'No Payments',
            message: 'No payments recorded for this borrower',
          );
        }

        final totalPaid = controller.payments.fold<double>(
          0.0,
          (sum, payment) => sum + payment.amount,
        );

        return Column(
          children: [
            // Summary Card
            Card(
              margin: const EdgeInsets.all(16),
              color: Get.theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Payments',
                          style: Get.theme.textTheme.titleMedium?.copyWith(
                            color: Get.theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          NumberFormat('#,##0.00').format(totalPaid),
                          style: Get.theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Get.theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Number of Payments',
                          style: Get.theme.textTheme.titleMedium?.copyWith(
                            color: Get.theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          '${controller.payments.length}',
                          style: Get.theme.textTheme.titleLarge?.copyWith(
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
            // Payments List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.payments.length,
                itemBuilder: (context, index) {
                  final payment = controller.payments[index];
                  final loan = payment.loanId != null 
                      ? DatabaseService.getLoan(payment.loanId!)
                      : null;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Get.theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.payment,
                          color: Get.theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        NumberFormat('#,##0.00').format(payment.amount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormatter.formatDisplay(payment.date),
                          ),
                          if (loan != null) ...[
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () {
                                Get.to(() => LoanDetailScreen(loanId: loan.id));
                              },
                              child: Text(
                                'Loan: ${NumberFormat('#,##0.00').format(loan.amount)}',
                                style: TextStyle(
                                  color: Get.theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 4),
                            Chip(
                              label: const Text(
                                'All Loans',
                                style: TextStyle(fontSize: 10),
                              ),
                              backgroundColor: Get.theme.colorScheme.secondaryContainer,
                            ),
                          ],
                          if (payment.paymentType != null) ...[
                            const SizedBox(height: 4),
                            Chip(
                              label: Text(
                                payment.paymentType!,
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor:
                                  Get.theme.colorScheme.surfaceContainerHighest,
                            ),
                          ],
                          if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              payment.notes!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Get.theme.colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Get.theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                const Text('Edit'),
                              ],
                            ),
                            onTap: () async {
                              await Future.delayed(const Duration(milliseconds: 100));
                              final result = await Get.to(() => EditPaymentScreen(payment: payment));
                              if (result == true) {
                                // Refresh payments and borrower data
                                await controller.loadPaymentsByBorrower(borrowerId);
                                try {
                                  final borrowerController = Get.find<BorrowerController>();
                                  await borrowerController.loadBorrowers();
                                } catch (e) {
                                  // Controller might not be initialized
                                }
                              }
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
                              _showDeleteDialog(context, payment, controller);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    PaymentModel payment,
    PaymentController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Payment'),
        content: Text(
          'Are you sure you want to delete this payment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deletePayment(
                payment.id,
                loanId: payment.loanId,
                borrowerId: payment.borrowerId,
              );
              if (success) {
                // Refresh borrower data
                try {
                  final borrowerController = Get.find<BorrowerController>();
                  await borrowerController.loadBorrowers();
                } catch (e) {
                  // Controller might not be initialized
                }
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

