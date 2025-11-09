import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/asset_controller.dart';
import 'asset_form_screen.dart';
import 'asset_detail_screen.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';
import '../../../models/asset_model.dart';
import '../../../services/database_service.dart';

class AssetListScreen extends StatelessWidget {
  const AssetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AssetController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => const AssetFormScreen());
            },
            tooltip: 'Add Asset',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              hintText: 'Search assets...',
              prefixIcon: Icons.search,
              onChanged: (value) {
                controller.setSearchQuery(value);
              },
            ),
          ),
          // Filter chips
          SizedBox(
            height: 50,
            child: Obx(() {
              // Access observable to make Obx reactive
              final _ = controller.filterType.value;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip(
                      controller,
                      label: 'All',
                      type: null,
                    ),
                    const SizedBox(width: 8),
                    ...AssetType.values.map((type) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(
                            controller,
                            label: _getAssetTypeLabel(type),
                            type: type,
                          ),
                        )),
                  ],
                ),
              );
            }),
          ),
          // Summary card
          Obx(() {
            // Access observable to make Obx reactive
            final _ = controller.assets.length;
            return _buildSummaryCard(controller);
          }),
          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredAssets.isEmpty) {
                return EmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: controller.searchQuery.value.isEmpty &&
                          controller.filterType.value == null
                      ? 'No Assets Yet'
                      : 'No Results Found',
                  message: controller.searchQuery.value.isEmpty &&
                          controller.filterType.value == null
                      ? 'Add your first asset to start tracking'
                      : 'Try adjusting your search or filter',
                  actionLabel: controller.searchQuery.value.isEmpty &&
                          controller.filterType.value == null
                      ? 'Add Asset'
                      : null,
                  onAction: controller.searchQuery.value.isEmpty &&
                          controller.filterType.value == null
                      ? () => Get.to(() => const AssetFormScreen())
                      : null,
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadAssets(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.filteredAssets.length,
                  itemBuilder: (context, index) {
                    final asset = controller.filteredAssets[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: _getAssetTypeColor(asset.type),
                          child: Icon(
                            _getAssetTypeIcon(asset.type),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          asset.name,
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
                                    _getAssetTypeLabel(asset.type),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: _getAssetTypeColor(asset.type)
                                      .withOpacity(0.2),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                                if (asset.type == AssetType.gold ||
                                    asset.type == AssetType.silver)
                                  if (asset.weightInGrams != null)
                                    Chip(
                                      label: Text(
                                        '${NumberFormat('#,##0.00').format(asset.weightInGrams)} g',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      backgroundColor: Get.theme.colorScheme.surfaceContainerHighest,
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Value: ${NumberFormat('#,##0.00').format(asset.value)} ${asset.currency}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Date: ${DateFormat('MMM dd, yyyy').format(asset.valuationDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Get.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Get.to(() => AssetDetailScreen(assetId: asset.id));
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

  Widget _buildFilterChip(AssetController controller,
      {required String label, AssetType? type}) {
    final isSelected = controller.filterType.value == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        controller.setTypeFilter(selected ? type : null);
      },
    );
  }

  Widget _buildSummaryCard(AssetController controller) {
    final totalValue = controller.getTotalAssetsValue();
    final settings = DatabaseService.getSettings();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  'Total Assets',
                  style: Get.theme.textTheme.titleSmall?.copyWith(
                    color: Get.theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${NumberFormat('#,##0.00').format(totalValue)} ${settings.currency}',
                  style: Get.theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Get.theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.account_balance_wallet,
              size: 40,
              color: Get.theme.colorScheme.onPrimaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  String _getAssetTypeLabel(AssetType type) {
    switch (type) {
      case AssetType.cash:
        return 'Cash';
      case AssetType.bank:
        return 'Bank';
      case AssetType.gold:
        return 'Gold';
      case AssetType.silver:
        return 'Silver';
      case AssetType.investment:
        return 'Investment';
      case AssetType.property:
        return 'Property';
      case AssetType.business:
        return 'Business';
      case AssetType.other:
        return 'Other';
    }
  }

  IconData _getAssetTypeIcon(AssetType type) {
    switch (type) {
      case AssetType.cash:
        return Icons.money;
      case AssetType.bank:
        return Icons.account_balance;
      case AssetType.gold:
        return Icons.stars;
      case AssetType.silver:
        return Icons.star_border;
      case AssetType.investment:
        return Icons.trending_up;
      case AssetType.property:
        return Icons.home;
      case AssetType.business:
        return Icons.business;
      case AssetType.other:
        return Icons.category;
    }
  }

  Color _getAssetTypeColor(AssetType type) {
    switch (type) {
      case AssetType.cash:
        return Colors.green;
      case AssetType.bank:
        return Colors.blue;
      case AssetType.gold:
        return Colors.amber;
      case AssetType.silver:
        return Colors.grey;
      case AssetType.investment:
        return Colors.purple;
      case AssetType.property:
        return Colors.brown;
      case AssetType.business:
        return Colors.indigo;
      case AssetType.other:
        return Colors.teal;
    }
  }
}

