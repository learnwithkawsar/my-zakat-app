import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/zakat_year_controller.dart';
import '../../../models/zakat_record_model.dart';
import '../../../services/database_service.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../modules/zakat/screens/zakat_history_screen.dart';
import 'zakat_year_form_screen.dart';

class ZakatYearListScreen extends StatelessWidget {
  const ZakatYearListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ZakatYearController());
    final settings = DatabaseService.getSettings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zakat Years'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => const ZakatYearFormScreen());
            },
            tooltip: 'Add Zakat Year',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.zakatYears.isEmpty) {
          return EmptyState(
            icon: Icons.calendar_today,
            title: 'No Zakat Years',
            message: 'Create your first zakat year to get started',
            actionLabel: 'Add Zakat Year',
            onAction: () {
              Get.to(() => const ZakatYearFormScreen());
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadZakatYears(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.zakatYears.length,
            itemBuilder: (context, index) {
              final year = controller.zakatYears[index];
              final payments = DatabaseService.getZakatPaymentsByRecord(year.id);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: year.isCurrent ? 4 : 1,
                color: year.isCurrent
                    ? Get.theme.colorScheme.primaryContainer.withOpacity(0.3)
                    : null,
                child: InkWell(
                  onTap: () {
                    Get.to(() => ZakatYearDetailScreen(zakatYearId: year.id));
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  if (year.isCurrent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Get.theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'CURRENT',
                                        style: TextStyle(
                                          color: Get.theme.colorScheme.onPrimary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (year.isCurrent) const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      year.zakatYear,
                                      style: Get.theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                if (!year.isCurrent)
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Set as Current'),
                                      ],
                                    ),
                                    onTap: () async {
                                      await Future.delayed(
                                        const Duration(milliseconds: 100),
                                      );
                                      await controller.setAsCurrent(year.id);
                                    },
                                  ),
                                PopupMenuItem(
                                  child: const Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                  onTap: () async {
                                    await Future.delayed(
                                      const Duration(milliseconds: 100),
                                    );
                                    Get.to(() => ZakatYearFormScreen(
                                          zakatYear: year,
                                        ));
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Row(
                                    children: [
                                      Icon(Icons.calculate, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text('Recalculate'),
                                    ],
                                  ),
                                  onTap: () async {
                                    await Future.delayed(
                                      const Duration(milliseconds: 100),
                                    );
                                    await controller.recalculateZakatYear(
                                      name: year.name,
                                      startDate: year.zakatYearStart,
                                      endDate: year.zakatYearEnd,
                                    );
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
                                      const Duration(milliseconds: 100),
                                    );
                                    _showDeleteDialog(context, year, controller);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${DateFormat('MMM dd, yyyy').format(year.zakatYearStart)} - ${DateFormat('MMM dd, yyyy').format(year.zakatYearEnd)}',
                          style: Get.theme.textTheme.bodySmall?.copyWith(
                            color: Get.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Zakat Due',
                                  style: Get.theme.textTheme.bodySmall,
                                ),
                                Text(
                                  '${NumberFormat('#,##0.00').format(year.zakatDue)} ${settings.currency}',
                                  style: Get.theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Balance',
                                  style: Get.theme.textTheme.bodySmall,
                                ),
                                Text(
                                  '${NumberFormat('#,##0.00').format(year.balance)} ${settings.currency}',
                                  style: Get.theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: year.balance > 0
                                        ? Get.theme.colorScheme.error
                                        : Get.theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (payments.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${payments.length} payment${payments.length > 1 ? 's' : ''} made',
                            style: Get.theme.textTheme.bodySmall?.copyWith(
                              color: Get.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        Text(
                          'Calculated: ${DateFormat('MMM dd, yyyy').format(year.calculationDate)}',
                          style: Get.theme.textTheme.bodySmall?.copyWith(
                            color: Get.theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ZakatRecordModel year,
    ZakatYearController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Zakat Year'),
        content: Text(
          'Are you sure you want to delete Zakat Year ${year.zakatYear}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteZakatYear(year.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
              foregroundColor: Get.theme.colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class ZakatYearDetailScreen extends StatelessWidget {
  final String zakatYearId;

  const ZakatYearDetailScreen({super.key, required this.zakatYearId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ZakatYearController>();
    final year = controller.getZakatYearById(zakatYearId);
    final settings = DatabaseService.getSettings();

    if (year == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Zakat Year Details')),
        body: const Center(child: Text('Year not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Zakat Year ${year.zakatYear}'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              if (!year.isCurrent)
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.star, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Set as Current'),
                    ],
                  ),
                  onTap: () async {
                    await Future.delayed(const Duration(milliseconds: 100));
                    await controller.setAsCurrent(year.id);
                  },
                ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
                onTap: () async {
                  await Future.delayed(const Duration(milliseconds: 100));
                  Get.to(() => ZakatYearFormScreen(zakatYear: year));
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Year Badge
            if (year.isCurrent)
              Card(
                color: Get.theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Get.theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'This is the current zakat year',
                        style: Get.theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Get.theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (year.isCurrent) const SizedBox(height: 16),
            // Navigate to full zakat details
            Card(
              child: ListTile(
                leading: const Icon(Icons.calculate),
                title: const Text('View Full Zakat Details'),
                subtitle: const Text('See breakdown and payment history'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Get.to(() => ZakatDetailScreen(zakatRecordId: year.id));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

