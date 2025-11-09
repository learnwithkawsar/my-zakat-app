import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/loan_controller.dart';
import '../../../models/loan_model.dart';
import '../../../models/borrower_model.dart';
import '../../../services/database_service.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';
import '../../../common/utils/date_formatter.dart';
import 'loan_form_screen.dart';
import 'loan_detail_screen.dart';

class LoanListScreen extends StatelessWidget {
  const LoanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoanController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => const LoanFormScreen());
            },
            tooltip: 'Add Loan',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              hintText: 'Search loans...',
              prefixIcon: Icons.search,
              onChanged: (value) {
                controller.setSearchQuery(value);
              },
            ),
          ),
          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredLoans.isEmpty) {
                return EmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: controller.searchQuery.value.isEmpty
                      ? 'No Loans Yet'
                      : 'No Results Found',
                  message: controller.searchQuery.value.isEmpty
                      ? 'Add your first loan to start tracking'
                      : 'Try adjusting your search query',
                  actionLabel: controller.searchQuery.value.isEmpty
                      ? 'Add Loan'
                      : null,
                  onAction: controller.searchQuery.value.isEmpty
                      ? () => Get.to(() => const LoanFormScreen())
                      : null,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.filteredLoans.length,
                itemBuilder: (context, index) {
                  final loan = controller.filteredLoans[index];
                  final borrower = DatabaseService.getBorrower(loan.borrowerId);
                  final outstanding = controller.getLoanOutstanding(loan.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Get.theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: Get.theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        borrower?.name ?? 'Unknown Borrower',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            NumberFormat('#,##0.00').format(loan.amount),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Outstanding: ${NumberFormat('#,##0.00').format(outstanding)}',
                            style: TextStyle(
                              color: outstanding > 0
                                  ? Get.theme.colorScheme.error
                                  : Get.theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            DateFormatter.formatDisplay(loan.transactionDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: Get.theme.colorScheme.onSurfaceVariant,
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
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const LoanFormScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

