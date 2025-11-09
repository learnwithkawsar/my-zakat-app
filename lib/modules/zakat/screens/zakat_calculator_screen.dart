import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/zakat_controller.dart';
import '../../../models/zakat_record_model.dart';
import '../../../services/database_service.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../../common/utils/error_handler.dart';
import 'zakat_history_screen.dart';
import 'zakat_payment_screen.dart';
import 'zakat_payment_history_screen.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  final controller = Get.put(ZakatController());
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set selected year to current year on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRecord = controller.getCurrentYearRecord();
      if (currentRecord != null) {
        controller.setSelectedYearRecord(currentRecord);
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _calculateZakat() async {
    // Only allow calculation for current year
    final selectedRecord = controller.selectedYearRecord.value;
    if (selectedRecord == null || !selectedRecord.isCurrent) {
      ErrorHandler.showWarning('You can only calculate zakat for the current year. Please select the current year first.');
      return;
    }
    
    final success = await controller.calculateCurrentYearZakat(
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    if (success) {
      _notesController.clear();
    }
  }

  void _showYearSelector(BuildContext context) {
    final allYears = controller.zakatRecords.toList()
      ..sort((a, b) => b.zakatYearStart.compareTo(a.zakatYearStart));
    
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Select Zakat Year',
                style: Get.theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            if (allYears.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 64,
                      color: Get.theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Zakat Years Found',
                      style: Get.theme.textTheme.titleMedium?.copyWith(
                        color: Get.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a zakat year first',
                      textAlign: TextAlign.center,
                      style: Get.theme.textTheme.bodySmall?.copyWith(
                        color: Get.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...allYears.map((yearRecord) {
                final isSelected = controller.selectedYearRecord.value?.id == yearRecord.id;
                final isCurrent = yearRecord.isCurrent;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCurrent
                        ? Get.theme.colorScheme.primaryContainer
                        : Get.theme.colorScheme.secondaryContainer,
                    child: Text(
                      yearRecord.zakatYearStart.year.toString().substring(2),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCurrent
                            ? Get.theme.colorScheme.onPrimaryContainer
                            : Get.theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          yearRecord.zakatYear,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? Get.theme.colorScheme.primary
                                : Get.theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (isCurrent)
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
                    ],
                  ),
                  subtitle: Text(
                    '${DateFormat('MMM dd, yyyy').format(yearRecord.zakatYearStart)} - ${DateFormat('MMM dd, yyyy').format(yearRecord.zakatYearEnd)}',
                    style: Get.theme.textTheme.bodySmall,
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Get.theme.colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    controller.setSelectedYearRecord(yearRecord);
                    Get.back();
                  },
                );
              }),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = DatabaseService.getSettings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zakat Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.payment),
            onPressed: () {
              Get.to(() => const ZakatPaymentHistoryScreen());
            },
            tooltip: 'Payment History',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Get.to(() => const ZakatHistoryScreen());
            },
            tooltip: 'View History',
          ),
        ],
      ),
      body: Obx(() {
        final record = controller.selectedYearRecord.value;
        final isCurrentYear = record?.isCurrent ?? false;

        return RefreshIndicator(
          onRefresh: () => controller.loadZakatRecords(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Year Selector Card
                _buildYearSelectorCard(record, isCurrentYear, context),
                const SizedBox(height: 16),
                // Calculate Button (only show if current year is selected)
                if (isCurrentYear) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: controller.isCalculating.value ? null : _calculateZakat,
                      icon: controller.isCalculating.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.calculate),
                      label: Text(
                        controller.isCalculating.value
                            ? 'Calculating...'
                            : record == null
                                ? 'Calculate Zakat'
                                : 'Recalculate Zakat',
                      ),
                    ),
                  ),
                ],
                if (!isCurrentYear && record != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Get.theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You can only calculate zakat for the current year. Please select the current year to calculate.',
                            style: Get.theme.textTheme.bodyMedium?.copyWith(
                              color: Get.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (record != null) ...[
                  // Only show breakdown and zakat due if zakat has been calculated
                  if (record.isCalculated) ...[
                    const SizedBox(height: 16),
                    // Breakdown Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Calculation Breakdown',
                              style: Get.theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildBreakdownRow(
                              'Total Assets',
                              record.assetsTotal,
                              Icons.account_balance_wallet,
                              Colors.green,
                            ),
                            const SizedBox(height: 12),
                            _buildBreakdownRow(
                              'Total Receivables',
                              record.receivablesTotal,
                              Icons.receipt_long,
                              Colors.blue,
                            ),
                            const SizedBox(height: 12),
                            _buildBreakdownRow(
                              'Total Liabilities',
                              record.liabilitiesTotal,
                              Icons.credit_card,
                              Colors.red,
                              isNegative: true,
                            ),
                            const Divider(height: 32),
                            _buildBreakdownRow(
                              'Net Zakatable Amount',
                              record.netZakatableAmount,
                              Icons.calculate,
                              Get.theme.colorScheme.primary,
                              isBold: true,
                            ),
                            const SizedBox(height: 8),
                            if (record.netZakatableAmount < settings.nisab)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.orange.shade900),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Below nisab threshold (${NumberFormat('#,##0.00').format(settings.nisab)} ${settings.currency})',
                                        style: TextStyle(
                                          color: Colors.orange.shade900,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Zakat Due Card
                    Card(
                      color: Get.theme.colorScheme.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Zakat Due',
                              style: Get.theme.textTheme.titleMedium?.copyWith(
                                color: Get.theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${NumberFormat('#,##0.00').format(record.zakatDue)} ${settings.currency}',
                              style: Get.theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Get.theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rate: ${settings.zakatRate}%',
                              style: Get.theme.textTheme.bodySmall?.copyWith(
                                color: Get.theme.colorScheme.onSecondaryContainer,
                              ),
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
                                  style: Get.theme.textTheme.titleMedium?.copyWith(
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
                            _buildPaymentRow('Zakat Due', record.zakatDue),
                            _buildPaymentRow('Amount Paid', record.amountPaid),
                            const Divider(),
                            _buildPaymentRow(
                              'Balance',
                              record.balance,
                              isBold: true,
                              color: record.balance > 0
                                  ? Get.theme.colorScheme.error
                                  : Get.theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Get.to(() => ZakatPaymentScreen(
                                        zakatRecordId: record.id,
                                        zakatYear: record.zakatYear,
                                      ));
                                },
                                icon: const Icon(Icons.payment),
                                label: const Text('Pay Zakat'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Show message if zakat hasn't been calculated yet
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.calculate_outlined,
                            size: 64,
                            color: Get.theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Zakat Not Calculated',
                            style: Get.theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Get.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please calculate zakat for this year to see the breakdown and zakat due amount.',
                            textAlign: TextAlign.center,
                            style: Get.theme.textTheme.bodyMedium?.copyWith(
                              color: Get.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (isCurrentYear) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: controller.isCalculating.value ? null : _calculateZakat,
                                icon: controller.isCalculating.value
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.calculate),
                                label: Text(
                                  controller.isCalculating.value
                                      ? 'Calculating...'
                                      : 'Calculate Zakat',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Notes Section
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
                          CustomTextField(
                            controller: _notesController,
                            hintText: 'Add notes (optional)',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 8),
                          if (isCurrentYear && record.isCalculated)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: controller.isCalculating.value
                                    ? null
                                    : _calculateZakat,
                                icon: const Icon(Icons.update),
                                label: const Text('Update Calculation'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildYearSelectorCard(ZakatRecordModel? record, bool isCurrentYear, BuildContext context) {
    return Card(
      color: Get.theme.colorScheme.primaryContainer,
      child: InkWell(
        onTap: () => _showYearSelector(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Zakat Year',
                    style: Get.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Get.theme.colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (record != null) ...[
                Row(
                  children: [
                    if (isCurrentYear)
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
                    if (isCurrentYear) const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record.zakatYear,
                        style: Get.theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Get.theme.colorScheme.onPrimaryContainer,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('MMM dd, yyyy').format(record.zakatYearStart)} - ${DateFormat('MMM dd, yyyy').format(record.zakatYearEnd)}',
                  style: Get.theme.textTheme.bodyMedium?.copyWith(
                    color: Get.theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
              if (record == null)
                Text(
                  'Tap to select a zakat year',
                  style: Get.theme.textTheme.bodyMedium?.copyWith(
                    color: Get.theme.colorScheme.onPrimaryContainer,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    double amount,
    IconData icon,
    Color color, {
    bool isNegative = false,
    bool isBold = false,
  }) {
    final settings = DatabaseService.getSettings();
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          '${isNegative ? '-' : ''}${NumberFormat('#,##0.00').format(amount)} ${settings.currency}',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isNegative ? Get.theme.colorScheme.error : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(String label, double amount,
      {bool isBold = false, Color? color}) {
    final settings = DatabaseService.getSettings();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
            '${NumberFormat('#,##0.00').format(amount)} ${settings.currency}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

