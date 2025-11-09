import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/beneficiary_controller.dart';
import 'beneficiary_form_screen.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';
import '../../../models/beneficiary_model.dart';

class BeneficiaryListScreen extends StatelessWidget {
  const BeneficiaryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BeneficiaryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficiaries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => const BeneficiaryFormScreen());
            },
            tooltip: 'Add Beneficiary',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              hintText: 'Search beneficiaries...',
              prefixIcon: Icons.search,
              onChanged: (value) {
                controller.setSearchQuery(value);
              },
            ),
          ),
          // Summary card
          Obx(() => _buildSummaryCard(controller)),
          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredBeneficiaries.isEmpty) {
                return EmptyState(
                  icon: Icons.people_outline,
                  title: controller.searchQuery.value.isEmpty
                      ? 'No Beneficiaries Yet'
                      : 'No Results Found',
                  message: controller.searchQuery.value.isEmpty
                      ? 'Add beneficiaries to track zakat distribution'
                      : 'Try adjusting your search query',
                  actionLabel: controller.searchQuery.value.isEmpty
                      ? 'Add Beneficiary'
                      : null,
                  onAction: controller.searchQuery.value.isEmpty
                      ? () => Get.to(() => const BeneficiaryFormScreen())
                      : null,
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadBeneficiaries(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.filteredBeneficiaries.length,
                  itemBuilder: (context, index) {
                    final beneficiary = controller.filteredBeneficiaries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Get.theme.colorScheme.primaryContainer,
                          child: Text(
                            beneficiary.name[0].toUpperCase(),
                            style: TextStyle(
                              color: Get.theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          beneficiary.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (beneficiary.contactInfo != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 16,
                                    color: Get.theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    beneficiary.contactInfo!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Get.theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (beneficiary.percentageShare != null) ...[
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(
                                  '${NumberFormat('#,##0.00').format(beneficiary.percentageShare)}% share',
                                  style: const TextStyle(fontSize: 10),
                                ),
                                backgroundColor:
                                    Get.theme.colorScheme.secondaryContainer,
                              ),
                            ],
                            if (beneficiary.notes != null &&
                                beneficiary.notes!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                beneficiary.notes!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Get.theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Get.to(() => BeneficiaryFormScreen(beneficiary: beneficiary));
                        },
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BeneficiaryController controller) {
    final totalCount = controller.getTotalBeneficiariesCount();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Get.theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Beneficiaries',
                  style: Get.theme.textTheme.titleSmall?.copyWith(
                    color: Get.theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalCount.toString(),
                  style: Get.theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Get.theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.people,
              size: 40,
              color: Get.theme.colorScheme.onSecondaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}

