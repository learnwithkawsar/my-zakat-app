import 'package:get/get.dart';
import 'package:collection/collection.dart';
import '../../../models/asset_model.dart';
import '../../../services/database_service.dart';
import '../../../common/utils/error_handler.dart';

class AssetController extends GetxController {
  final assets = <AssetModel>[].obs;
  final filteredAssets = <AssetModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final filterType = Rxn<AssetType>();

  @override
  void onInit() {
    super.onInit();
    loadAssets();
  }

  /// Load all assets from database
  Future<void> loadAssets() async {
    isLoading.value = true;
    try {
      final allAssets = DatabaseService.getAllAssets();
      assets.value = allAssets;
      assets.sort((a, b) => b.valuationDate.compareTo(a.valuationDate));
      filterAssets();
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Failed to load assets');
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter assets based on search query and type
  void filterAssets() {
    var filtered = assets.toList();

    // Filter by type
    if (filterType.value != null) {
      filtered = filtered.where((asset) => asset.type == filterType.value).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((asset) {
        return asset.name.toLowerCase().contains(query) ||
            (asset.notes != null && asset.notes!.toLowerCase().contains(query));
      }).toList();
    }

    filteredAssets.assignAll(filtered);
  }

  /// Set search query and filter
  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterAssets();
  }

  /// Set type filter
  void setTypeFilter(AssetType? type) {
    filterType.value = type;
    filterAssets();
  }

  /// Add new asset
  Future<bool> addAsset(AssetModel asset) async {
    try {
      await DatabaseService.addAsset(asset);
      await loadAssets();
      return true;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Failed to add asset');
      return false;
    }
  }

  /// Update existing asset
  Future<bool> updateAsset(AssetModel asset) async {
    try {
      await DatabaseService.updateAsset(asset);
      await loadAssets();
      return true;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Failed to update asset');
      return false;
    }
  }

  /// Delete asset
  Future<bool> deleteAsset(String id) async {
    try {
      await DatabaseService.deleteAsset(id);
      await loadAssets();
      ErrorHandler.showSuccess('Asset deleted successfully');
      return true;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Failed to delete asset');
      return false;
    }
  }

  /// Get asset by ID
  AssetModel? getAssetById(String id) {
    return assets.firstWhereOrNull((asset) => asset.id == id);
  }

  /// Get total assets value
  double getTotalAssetsValue() {
    return assets.fold<double>(0.0, (sum, asset) => sum + asset.value);
  }

  /// Get total assets value by type
  double getTotalAssetsValueByType(AssetType type) {
    return assets
        .where((asset) => asset.type == type)
        .fold<double>(0.0, (sum, asset) => sum + asset.value);
  }

  /// Get assets count by type
  int getAssetsCountByType(AssetType type) {
    return assets.where((asset) => asset.type == type).length;
  }
}

