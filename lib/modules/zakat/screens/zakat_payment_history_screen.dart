import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../controllers/zakat_controller.dart';
import '../../../models/zakat_payment_model.dart';
import '../../../models/zakat_record_model.dart';
import '../../../models/beneficiary_model.dart';
import '../../../services/database_service.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/utils/date_formatter.dart';
import 'zakat_payment_screen.dart';
import 'zakat_history_screen.dart';

class ZakatPaymentHistoryScreen extends StatefulWidget {
  const ZakatPaymentHistoryScreen({super.key});

  @override
  State<ZakatPaymentHistoryScreen> createState() =>
      _ZakatPaymentHistoryScreenState();
}

class _ZakatPaymentHistoryScreenState
    extends State<ZakatPaymentHistoryScreen> {
  final controller = Get.find<ZakatController>();
  String? _selectedYear;
  String? _selectedBeneficiaryId;

  @override
  void initState() {
    super.initState();
    // Use postFrameCallback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadZakatRecords();
    });
  }

  List<ZakatPaymentModel> _getFilteredPayments() {
    final allPayments = DatabaseService.getAllZakatPayments();
    
    var filtered = allPayments;

    // Filter by year
    if (_selectedYear != null) {
      filtered = filtered.where((payment) {
        final record = DatabaseService.getZakatRecord(payment.zakatRecordId);
        return record?.zakatYear == _selectedYear;
      }).toList();
    }

    // Filter by beneficiary
    if (_selectedBeneficiaryId != null) {
      filtered = filtered.where((payment) {
        return payment.beneficiaryId == _selectedBeneficiaryId;
      }).toList();
    }

    return filtered;
  }

  List<String> _getAvailableYears() {
    final years = controller.zakatRecords
        .map((record) => record.zakatYear)
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  double _getTotalAmount(List<ZakatPaymentModel> payments) {
    return payments.fold<double>(
        0.0, (sum, payment) => sum + payment.amount);
  }

  @override
  Widget build(BuildContext context) {
    final settings = DatabaseService.getSettings();
    final beneficiaries = DatabaseService.getAllBeneficiaries();
    final availableYears = _getAvailableYears();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zakat Payment History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Get.to(() => const ZakatHistoryScreen());
            },
            tooltip: 'View Zakat Records',
          ),
        ],
      ),
      body: Obx(() {
        // Access observable to make the whole body reactive to controller changes
        final _ = controller.zakatRecords.length;
        
        return Column(
          children: [
            // Filters
            Card(
              margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: Get.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Year Filter
                  DropdownButtonFormField<String>(
                    value: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Year',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Years'),
                      ),
                      ...availableYears.map((year) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Text(year),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Beneficiary Filter
                  DropdownButtonFormField<String>(
                    value: _selectedBeneficiaryId,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Beneficiary',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Beneficiaries'),
                      ),
                      ...beneficiaries.map((beneficiary) {
                        return DropdownMenuItem<String>(
                          value: beneficiary.id,
                          child: Text(beneficiary.name),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedBeneficiaryId = value;
                      });
                    },
                  ),
                  if (_selectedYear != null || _selectedBeneficiaryId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedYear = null;
                            _selectedBeneficiaryId = null;
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear Filters'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Summary Card
          Builder(
            builder: (context) {
              final filteredPayments = _getFilteredPayments();
              final totalAmount = _getTotalAmount(filteredPayments);

              return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Get.theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Payments',
                          style: Get.theme.textTheme.titleMedium?.copyWith(
                            color: Get.theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${filteredPayments.length} payment${filteredPayments.length != 1 ? 's' : ''}',
                          style: Get.theme.textTheme.bodySmall?.copyWith(
                            color: Get.theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${NumberFormat('#,##0.00').format(totalAmount)} ${settings.currency}',
                          style: Get.theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Get.theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          'Total Amount',
                          style: Get.theme.textTheme.bodySmall?.copyWith(
                            color: Get.theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
            },
          ),
          // Payments List
          Expanded(
            child: Builder(
              builder: (context) {
                final filteredPayments = _getFilteredPayments();

              if (filteredPayments.isEmpty) {
                return EmptyState(
                  icon: Icons.payment_outlined,
                  title: _selectedYear != null || _selectedBeneficiaryId != null
                      ? 'No Payments Found'
                      : 'No Payments Yet',
                  message: _selectedYear != null ||
                          _selectedBeneficiaryId != null
                      ? 'Try adjusting your filters'
                      : 'Zakat payments will appear here once you make your first payment',
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadZakatRecords(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPayments.length,
                  itemBuilder: (context, index) {
                    final payment = filteredPayments[index];
                    final beneficiary =
                        DatabaseService.getBeneficiary(payment.beneficiaryId);
                    final zakatRecord =
                        DatabaseService.getZakatRecord(payment.zakatRecordId);
                    final isLast = index == filteredPayments.length - 1;

                    return Column(
                      children: [
                        Card(
                          elevation: 2,
                          margin: EdgeInsets.zero,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              _showPaymentDetails(payment, beneficiary, zakatRecord);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor:
                                            Get.theme.colorScheme.primaryContainer,
                                        child: Text(
                                          beneficiary?.name.isNotEmpty == true
                                              ? beneficiary!.name[0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Get.theme
                                                .colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              beneficiary?.name ??
                                                  'Unknown Beneficiary',
                                              style: Get.theme.textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (zakatRecord != null) ...[
                                              const SizedBox(height: 2),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 12,
                                                    color: Get.theme.colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      'Zakat Year ${zakatRecord.zakatYear}',
                                                      style: Get.theme.textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                        color: Get.theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${NumberFormat('#,##0.00').format(payment.amount)} ${settings.currency}',
                                            style: Get.theme.textTheme
                                                .titleLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Get.theme
                                                  .colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat('MMM dd, yyyy')
                                                .format(payment.paymentDate),
                                            style: Get.theme.textTheme
                                                .bodySmall
                                                ?.copyWith(
                                              color: Get.theme.colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (payment.notes != null &&
                                      payment.notes!.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Get.theme.colorScheme
                                            .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.note,
                                            size: 16,
                                            color: Get.theme.colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              payment.notes!,
                                              style: Get.theme.textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                fontStyle: FontStyle.italic,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (!isLast) const SizedBox(height: 12),
                      ],
                    );
                  },
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

  void _showPaymentDetails(
    ZakatPaymentModel payment,
    BeneficiaryModel? beneficiary,
    ZakatRecordModel? zakatRecord,
  ) {
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
              if (zakatRecord != null)
                _buildPaymentDetailRow(
                  'Zakat Year',
                  zakatRecord.zakatYear,
                ),
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
              Row(
                children: [
                  if (zakatRecord != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          Get.to(() => ZakatDetailScreen(
                                zakatRecordId: zakatRecord.id,
                              ));
                        },
                        icon: const Icon(Icons.history),
                        label: const Text('View Zakat Year'),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
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

