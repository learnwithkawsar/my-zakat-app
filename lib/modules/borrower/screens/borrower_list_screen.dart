import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/borrower_controller.dart';
import 'borrower_form_screen.dart';
import 'borrower_detail_screen.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';
import '../../../services/database_service.dart';

class BorrowerListScreen extends StatelessWidget {
  const BorrowerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BorrowerController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrowers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => BorrowerFormScreen());
            },
            tooltip: 'Add Borrower',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              hintText: 'Search borrowers...',
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

              if (controller.filteredBorrowers.isEmpty) {
                return EmptyState(
                  icon: Icons.person_outline,
                  title: controller.searchQuery.value.isEmpty
                      ? 'No Borrowers Yet'
                      : 'No Results Found',
                  message: controller.searchQuery.value.isEmpty
                      ? 'Add your first borrower to start tracking loans'
                      : 'Try adjusting your search query',
                  actionLabel: controller.searchQuery.value.isEmpty
                      ? 'Add Borrower'
                      : null,
                  onAction: controller.searchQuery.value.isEmpty
                      ? () => Get.to(() => BorrowerFormScreen())
                      : null,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.filteredBorrowers.length,
                itemBuilder: (context, index) {
                  final borrower = controller.filteredBorrowers[index];
                  final outstanding = controller.getBorrowerOutstanding(borrower.id);
                  final settings = DatabaseService.getSettings();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Get.theme.colorScheme.primaryContainer,
                        child: Text(
                          borrower.name[0].toUpperCase(),
                          style: TextStyle(
                            color: Get.theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        borrower.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (borrower.contactInfo != null)
                            Text(borrower.contactInfo!),
                          const SizedBox(height: 4),
                          Text(
                            'Outstanding: ${NumberFormat('#,##0.00').format(outstanding)}',
                            style: TextStyle(
                              color: outstanding > 0
                                  ? Get.theme.colorScheme.error
                                  : Get.theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Get.theme.colorScheme.onSurfaceVariant,
                      ),
                      onTap: () {
                        Get.to(() => BorrowerDetailScreen(borrowerId: borrower.id));
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
          Get.to(() => BorrowerFormScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

