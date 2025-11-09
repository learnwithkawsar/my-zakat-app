import 'package:get/get.dart';
import '../../../models/liability_model.dart';
import '../../../services/database_service.dart';

class LiabilityController extends GetxController {
  final liabilities = <LiabilityModel>[].obs;
  final filteredLiabilities = <LiabilityModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final filterType = Rxn<LiabilityType>();
  final filterIncludeInZakat = Rxn<bool>();

  @override
  void onInit() {
    super.onInit();
    loadLiabilities();
  }

  /// Load all liabilities from database
  Future<void> loadLiabilities() async {
    isLoading.value = true;
    try {
      final allLiabilities = DatabaseService.getAllLiabilities();
      liabilities.value = allLiabilities;
      liabilities.sort((a, b) {
        // Sort by due date (nulls last), then by amount
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        } else if (a.dueDate != null) {
          return -1;
        } else if (b.dueDate != null) {
          return 1;
        }
        return b.amount.compareTo(a.amount);
      });
      filterLiabilities();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load liabilities: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter liabilities based on search query, type, and zakat inclusion
  void filterLiabilities() {
    var filtered = liabilities.toList();

    // Filter by type
    if (filterType.value != null) {
      filtered = filtered.where((liability) => liability.type == filterType.value).toList();
    }

    // Filter by include in zakat
    if (filterIncludeInZakat.value != null) {
      filtered = filtered
          .where((liability) => liability.includeInZakat == filterIncludeInZakat.value)
          .toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((liability) {
        return liability.creditorName.toLowerCase().contains(query) ||
            (liability.description != null &&
                liability.description!.toLowerCase().contains(query)) ||
            (liability.notes != null &&
                liability.notes!.toLowerCase().contains(query));
      }).toList();
    }

    filteredLiabilities.assignAll(filtered);
  }

  /// Set search query and filter
  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterLiabilities();
  }

  /// Set type filter
  void setTypeFilter(LiabilityType? type) {
    filterType.value = type;
    filterLiabilities();
  }

  /// Set include in zakat filter
  void setIncludeInZakatFilter(bool? include) {
    filterIncludeInZakat.value = include;
    filterLiabilities();
  }

  /// Add new liability
  Future<bool> addLiability(LiabilityModel liability) async {
    try {
      await DatabaseService.addLiability(liability);
      await loadLiabilities();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add liability: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Update existing liability
  Future<bool> updateLiability(LiabilityModel liability) async {
    try {
      await DatabaseService.updateLiability(liability);
      await loadLiabilities();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update liability: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Delete liability
  Future<bool> deleteLiability(String id) async {
    try {
      await DatabaseService.deleteLiability(id);
      await loadLiabilities();
      Get.snackbar(
        'Success',
        'Liability deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete liability: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Get liability by ID
  LiabilityModel? getLiabilityById(String id) {
    return liabilities.firstWhereOrNull((liability) => liability.id == id);
  }

  /// Get total liabilities amount
  double getTotalLiabilitiesAmount() {
    return liabilities.fold<double>(0.0, (sum, liability) => sum + liability.amount);
  }

  /// Get total liabilities amount by type
  double getTotalLiabilitiesAmountByType(LiabilityType type) {
    return liabilities
        .where((liability) => liability.type == type)
        .fold<double>(0.0, (sum, liability) => sum + liability.amount);
  }

  /// Get total included liabilities amount (for zakat)
  double getTotalIncludedLiabilitiesAmount() {
    return liabilities
        .where((liability) => liability.includeInZakat)
        .fold<double>(0.0, (sum, liability) => sum + liability.amount);
  }

  /// Toggle include in zakat
  Future<bool> toggleIncludeInZakat(String id) async {
    final liability = getLiabilityById(id);
    if (liability == null) return false;

    final updated = liability.copyWith(includeInZakat: !liability.includeInZakat);
    return await updateLiability(updated);
  }
}

