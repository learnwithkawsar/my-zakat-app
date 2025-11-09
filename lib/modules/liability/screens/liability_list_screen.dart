import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/liability_controller.dart';
import 'liability_form_screen.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';
import '../../../models/liability_model.dart';
import '../../../services/database_service.dart';
import '../../../common/utils/date_formatter.dart';

class LiabilityListScreen extends StatelessWidget {
  const LiabilityListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LiabilityController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liabilities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => const LiabilityFormScreen());
            },
            tooltip: 'Add Liability',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              hintText: 'Search liabilities...',
              prefixIcon: Icons.search,
              onChanged: (value) {
                controller.setSearchQuery(value);
              },
            ),
          ),
          // Filter chips
          Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip(
                      controller,
                      label: 'All',
                      type: null,
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Short-term'),
                      selected: controller.filterType.value == LiabilityType.shortTerm,
                      onSelected: (selected) {
                        controller.setTypeFilter(
                            selected ? LiabilityType.shortTerm : null);
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Long-term'),
                      selected: controller.filterType.value == LiabilityType.longTerm,
                      onSelected: (selected) {
                        controller.setTypeFilter(
                            selected ? LiabilityType.longTerm : null);
                      },
                    ),
                  ],
                ),
              )),
          // Summary card
          Obx(() => _buildSummaryCard(controller)),
          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredLiabilities.isEmpty) {
                return EmptyState(
                  icon: Icons.credit_card_outlined,
                  title: controller.searchQuery.value.isEmpty &&
                          controller.filterType.value == null
                      ? 'No Liabilities Yet'
                      : 'No Results Found',
                  message: controller.searchQuery.value.isEmpty &&
                          controller.filterType.value == null
                      ? 'Add your first liability to start tracking'
                      : 'Try adjusting your search or filter',
                  actionLabel: controller.searchQuery.value.isEmpty &&
                          controller.filterType.value == null
                      ? 'Add Liability'
                      : null,
                  onAction: controller.searchQuery.value.isEmpty &&
                          controller.filterType.value == null
                      ? () => Get.to(() => const LiabilityFormScreen())
                      : null,
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadLiabilities(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.filteredLiabilities.length,
                  itemBuilder: (context, index) {
                    final liability = controller.filteredLiabilities[index];
                    final isOverdue = liability.dueDate != null &&
                        DateFormatter.isOverdue(liability.dueDate);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isOverdue
                          ? Get.theme.colorScheme.errorContainer.withOpacity(0.3)
                          : null,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: liability.type == LiabilityType.shortTerm
                              ? Colors.orange
                              : Colors.blue,
                          child: Icon(
                            liability.type == LiabilityType.shortTerm
                                ? Icons.schedule
                                : Icons.calendar_today,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          liability.creditorName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Chip(
                                  label: Text(
                                    liability.type == LiabilityType.shortTerm
                                        ? 'Short-term'
                                        : 'Long-term',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: liability.type ==
                                          LiabilityType.shortTerm
                                      ? Colors.orange.withOpacity(0.2)
                                      : Colors.blue.withOpacity(0.2),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                                if (!liability.includeInZakat)
                                  Chip(
                                    label: const Text(
                                      'Excluded',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    backgroundColor: Colors.orange.withOpacity(0.2),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Amount: ${NumberFormat('#,##0.00').format(liability.amount)} ${liability.currency}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (liability.dueDate != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  'Due: ${DateFormatter.formatDisplay(liability.dueDate!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isOverdue
                                        ? Get.theme.colorScheme.error
                                        : Get.theme.colorScheme.onSurfaceVariant,
                                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            if (liability.description != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  liability.description!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Get.theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  Icon(
                                    liability.includeInZakat
                                        ? Icons.block
                                        : Icons.check_circle,
                                    color: liability.includeInZakat
                                        ? Colors.orange
                                        : Get.theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(liability.includeInZakat
                                      ? 'Exclude from Zakat'
                                      : 'Include in Zakat'),
                                ],
                              ),
                              onTap: () async {
                                await Future.delayed(
                                    const Duration(milliseconds: 100));
                                await controller.toggleIncludeInZakat(liability.id);
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
                                await Future.delayed(
                                    const Duration(milliseconds: 100));
                                _showDeleteDialog(context, liability, controller);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Get.to(() => LiabilityFormScreen(liability: liability));
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

  Widget _buildFilterChip(LiabilityController controller,
      {required String label, LiabilityType? type}) {
    final isSelected = controller.filterType.value == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        controller.setTypeFilter(selected ? type : null);
      },
    );
  }

  Widget _buildSummaryCard(LiabilityController controller) {
    final totalAmount = controller.getTotalLiabilitiesAmount();
    final settings = DatabaseService.getSettings();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Get.theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Liabilities',
                  style: Get.theme.textTheme.titleSmall?.copyWith(
                    color: Get.theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${NumberFormat('#,##0.00').format(totalAmount)} ${settings.currency}',
                  style: Get.theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Get.theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.credit_card,
              size: 40,
              color: Get.theme.colorScheme.onErrorContainer,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    LiabilityModel liability,
    LiabilityController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Liability'),
        content: Text(
          'Are you sure you want to delete "${liability.creditorName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deleteLiability(liability.id);
              if (success) {
                // Already handled in controller
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

