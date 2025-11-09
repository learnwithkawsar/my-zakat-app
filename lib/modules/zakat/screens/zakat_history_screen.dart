import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../controllers/zakat_controller.dart';
import '../../../models/zakat_payment_model.dart';
import '../../../models/beneficiary_model.dart';
import '../../../services/database_service.dart';
import '../../../common/widgets/empty_state.dart';
import 'zakat_calculator_screen.dart';
import 'zakat_payment_screen.dart';
import 'zakat_payment_history_screen.dart';

class ZakatHistoryScreen extends StatelessWidget {
  const ZakatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ZakatController>();
    final settings = DatabaseService.getSettings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zakat History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.payment),
            onPressed: () {
              Get.to(() => const ZakatPaymentHistoryScreen());
            },
            tooltip: 'Payment History',
          ),
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () {
              Get.to(() => const ZakatCalculatorScreen());
            },
            tooltip: 'Calculate Zakat',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.zakatRecords.isEmpty) {
          return EmptyState(
            icon: Icons.history,
            title: 'No Zakat Records',
            message: 'Calculate zakat for the current year to get started',
            actionLabel: 'Calculate Zakat',
            onAction: () {
              Get.to(() => const ZakatCalculatorScreen());
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadZakatRecords(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.zakatRecords.length,
            itemBuilder: (context, index) {
              final record = controller.zakatRecords[index];
              final payments = controller.getPaymentsForRecord(record.id);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    Get.to(() => ZakatDetailScreen(zakatRecordId: record.id));
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
                              child: Text(
                                '${record.zakatYear}',
                                style: Get.theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (record.isFullyPaid)
                              Chip(
                                label: const Text('Paid'),
                                backgroundColor: Colors.green.shade100,
                                labelStyle: TextStyle(color: Colors.green.shade900),
                              )
                            else if (record.amountPaid > 0)
                              Chip(
                                label: const Text('Partial'),
                                backgroundColor: Colors.orange.shade100,
                                labelStyle: TextStyle(color: Colors.orange.shade900),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${DateFormat('MMM dd, yyyy').format(record.zakatYearStart)} - ${DateFormat('MMM dd, yyyy').format(record.zakatYearEnd)}',
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
                                  '${NumberFormat('#,##0.00').format(record.zakatDue)} ${settings.currency}',
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
                                  '${NumberFormat('#,##0.00').format(record.balance)} ${settings.currency}',
                                  style: Get.theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: record.balance > 0
                                        ? Get.theme.colorScheme.error
                                        : Get.theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (payments.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            '${payments.length} payment${payments.length > 1 ? 's' : ''} made',
                            style: Get.theme.textTheme.bodySmall?.copyWith(
                              color: Get.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Calculated: ${DateFormat('MMM dd, yyyy').format(record.calculationDate)}',
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
}

class ZakatDetailScreen extends StatelessWidget {
  final String zakatRecordId;

  const ZakatDetailScreen({super.key, required this.zakatRecordId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ZakatController>();
    final record = controller.zakatRecords.firstWhereOrNull(
      (r) => r.id == zakatRecordId,
    );
    final settings = DatabaseService.getSettings();

    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Zakat Details')),
        body: const Center(child: Text('Record not found')),
      );
    }

    final payments = controller.getPaymentsForRecord(zakatRecordId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Zakat Year ${record.zakatYear}'),
        actions: [
          if (record.balance > 0)
            IconButton(
              icon: const Icon(Icons.payment),
              onPressed: () {
                Get.to(() => ZakatPaymentScreen(
                      zakatRecordId: record.id,
                      zakatYear: record.zakatYear,
                    ));
              },
              tooltip: 'Pay Zakat',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: Get.theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Zakat Year', record.zakatYear),
                  _buildDetailRow(
                    'Period',
                    '${DateFormat('MMM dd, yyyy').format(record.zakatYearStart)} - ${DateFormat('MMM dd, yyyy').format(record.zakatYearEnd)}',
                  ),
                  _buildDetailRow(
                    'Calculated On',
                    DateFormat('MMM dd, yyyy').format(record.calculationDate),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Breakdown Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Breakdown',
                    style: Get.theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Total Assets',
                    '${NumberFormat('#,##0.00').format(record.assetsTotal)} ${settings.currency}',
                  ),
                  _buildDetailRow(
                    'Total Receivables',
                    '${NumberFormat('#,##0.00').format(record.receivablesTotal)} ${settings.currency}',
                  ),
                  _buildDetailRow(
                    'Total Liabilities',
                    '${NumberFormat('#,##0.00').format(record.liabilitiesTotal)} ${settings.currency}',
                  ),
                  const Divider(),
                  _buildDetailRow(
                    'Net Zakatable Amount',
                    '${NumberFormat('#,##0.00').format(record.netZakatableAmount)} ${settings.currency}',
                    isBold: true,
                  ),
                  _buildDetailRow(
                    'Zakat Rate',
                    '${settings.zakatRate}%',
                  ),
                  _buildDetailRow(
                    'Zakat Due',
                    '${NumberFormat('#,##0.00').format(record.zakatDue)} ${settings.currency}',
                    isBold: true,
                    color: Get.theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Payment Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Status',
                        style: Get.theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (record.isFullyPaid)
                        Chip(
                          label: const Text('Fully Paid'),
                          backgroundColor: Colors.green.shade100,
                          labelStyle: TextStyle(color: Colors.green.shade900),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Amount Paid',
                    '${NumberFormat('#,##0.00').format(record.amountPaid)} ${settings.currency}',
                  ),
                  _buildDetailRow(
                    'Balance',
                    '${NumberFormat('#,##0.00').format(record.balance)} ${settings.currency}',
                    isBold: true,
                    color: record.balance > 0
                        ? Get.theme.colorScheme.error
                        : Get.theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Payments List
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment History (${payments.length})',
                        style: Get.theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (record.balance > 0)
                        TextButton.icon(
                          onPressed: () async {
                            final result = await Get.to(() => ZakatPaymentScreen(
                                  zakatRecordId: record.id,
                                  zakatYear: record.zakatYear,
                                ));
                            if (result == true) {
                              // Refresh the detail screen by reloading the controller
                              controller.loadZakatRecords();
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Payment'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (payments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.payment_outlined,
                            size: 64,
                            color: Get.theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No payments made yet',
                            style: Get.theme.textTheme.titleMedium?.copyWith(
                              color: Get.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add a payment to start tracking zakat distribution',
                            textAlign: TextAlign.center,
                            style: Get.theme.textTheme.bodySmall?.copyWith(
                              color: Get.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Total paid summary
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Paid',
                            style: Get.theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Get.theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            '${NumberFormat('#,##0.00').format(record.amountPaid)} ${settings.currency}',
                            style: Get.theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Get.theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Payment list
                    ...payments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final payment = entry.value;
                      final beneficiary = DatabaseService.getBeneficiary(payment.beneficiaryId);
                      final isLast = index == payments.length - 1;
                      
                      return Column(
                        children: [
                          Card(
                            elevation: 1,
                            margin: EdgeInsets.zero,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                // Show payment details
                                _showPaymentDetails(payment, beneficiary);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Get.theme.colorScheme.primaryContainer,
                                      child: Text(
                                        beneficiary?.name.isNotEmpty == true
                                            ? beneficiary!.name[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          fontSize: 20,
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
                                            beneficiary?.name ?? 'Unknown Beneficiary',
                                            style: Get.theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 14,
                                                color: Get.theme.colorScheme.onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                DateFormat('MMM dd, yyyy').format(payment.paymentDate),
                                                style: Get.theme.textTheme.bodySmall?.copyWith(
                                                  color: Get.theme.colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (beneficiary?.contactInfo != null &&
                                              beneficiary!.contactInfo!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.contact_phone,
                                                  size: 14,
                                                  color: Get.theme.colorScheme.onSurfaceVariant,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    beneficiary.contactInfo!,
                                                    style: Get.theme.textTheme.bodySmall?.copyWith(
                                                      color: Get.theme.colorScheme.onSurfaceVariant,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          if (payment.notes != null &&
                                              payment.notes!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.note,
                                                  size: 14,
                                                  color: Get.theme.colorScheme.onSurfaceVariant,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    payment.notes!,
                                                    style: Get.theme.textTheme.bodySmall?.copyWith(
                                                      color: Get.theme.colorScheme.onSurfaceVariant,
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${NumberFormat('#,##0.00').format(payment.amount)} ${settings.currency}',
                                          style: Get.theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Get.theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Payment #${payments.length - index}',
                                          style: Get.theme.textTheme.bodySmall?.copyWith(
                                            color: Get.theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Get.theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (!isLast) const SizedBox(height: 8),
                        ],
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Get.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(record.notes!),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDetails(ZakatPaymentModel payment, BeneficiaryModel? beneficiary) {
    final settings = DatabaseService.getSettings();
    
    Get.dialog(
      Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Details',
                    style: Get.theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              if (beneficiary != null) ...[
                _buildPaymentDetailRow('Beneficiary', beneficiary.name),
                if (beneficiary.contactInfo != null &&
                    beneficiary.contactInfo!.isNotEmpty)
                  _buildPaymentDetailRow('Contact', beneficiary.contactInfo!),
              ],
              _buildPaymentDetailRow(
                'Amount',
                '${NumberFormat('#,##0.00').format(payment.amount)} ${settings.currency}',
                isBold: true,
                color: Get.theme.colorScheme.primary,
              ),
              _buildPaymentDetailRow(
                'Payment Date',
                DateFormat('MMM dd, yyyy').format(payment.paymentDate),
              ),
              _buildPaymentDetailRow(
                'Recorded On',
                DateFormat('MMM dd, yyyy hh:mm a').format(payment.createdAt),
              ),
              if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Notes',
                  style: Get.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  payment.notes!,
                  style: Get.theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetailRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Get.theme.textTheme.bodyMedium?.copyWith(
                color: Get.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

