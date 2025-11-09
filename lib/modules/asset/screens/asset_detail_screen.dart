import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/asset_controller.dart';
import '../../../models/asset_model.dart';
import '../../../services/database_service.dart';
import '../../../common/utils/date_formatter.dart';
import 'asset_form_screen.dart';

class AssetDetailScreen extends StatelessWidget {
  final String assetId;

  const AssetDetailScreen({super.key, required this.assetId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AssetController());
    final asset = controller.getAssetById(assetId);
    final settings = DatabaseService.getSettings();

    if (asset == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Asset Details')),
        body: const Center(child: Text('Asset not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(asset.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.to(() => AssetFormScreen(asset: asset));
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
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
                  _showDeleteDialog(context, asset, controller);
                },
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Asset Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: _getAssetTypeColor(asset.type),
                        child: Icon(
                          _getAssetTypeIcon(asset.type),
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              asset.name,
                              style: Get.theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Chip(
                              label: Text(_getAssetTypeLabel(asset.type)),
                              backgroundColor: _getAssetTypeColor(asset.type)
                                  .withOpacity(0.2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Value',
                    '${NumberFormat('#,##0.00').format(asset.value)} ${asset.currency}',
                    Icons.attach_money,
                  ),
                  if (asset.type == AssetType.gold ||
                      asset.type == AssetType.silver)
                    if (asset.weightInGrams != null)
                      _buildInfoRow(
                        'Weight',
                        '${NumberFormat('#,##0.00').format(asset.weightInGrams)} grams',
                        Icons.scale,
                      ),
                  _buildInfoRow(
                    'Valuation Date',
                    DateFormatter.formatDisplay(asset.valuationDate),
                    Icons.calendar_today,
                  ),
                  if (asset.notes != null && asset.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Notes',
                      style: Get.theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      asset.notes!,
                      style: Get.theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Get.theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Get.theme.textTheme.bodySmall?.copyWith(
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: Get.theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    AssetModel asset,
    AssetController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Asset'),
        content: Text(
          'Are you sure you want to delete "${asset.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deleteAsset(asset.id);
              if (success) {
                Get.back(); // Go back to list
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

