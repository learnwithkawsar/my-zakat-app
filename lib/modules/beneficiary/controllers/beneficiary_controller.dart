import 'package:get/get.dart';
import '../../../models/beneficiary_model.dart';
import '../../../services/database_service.dart';

class BeneficiaryController extends GetxController {
  final beneficiaries = <BeneficiaryModel>[].obs;
  final filteredBeneficiaries = <BeneficiaryModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadBeneficiaries();
  }

  /// Load all beneficiaries from database
  Future<void> loadBeneficiaries() async {
    isLoading.value = true;
    try {
      final allBeneficiaries = DatabaseService.getAllBeneficiaries();
      beneficiaries.value = allBeneficiaries;
      beneficiaries.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      filterBeneficiaries();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load beneficiaries: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter beneficiaries based on search query
  void filterBeneficiaries() {
    if (searchQuery.value.isEmpty) {
      filteredBeneficiaries.value = beneficiaries;
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredBeneficiaries.value = beneficiaries.where((beneficiary) {
        return beneficiary.name.toLowerCase().contains(query) ||
            (beneficiary.contactInfo?.toLowerCase().contains(query) ?? false) ||
            (beneficiary.notes != null &&
                beneficiary.notes!.toLowerCase().contains(query));
      }).toList();
    }
  }

  /// Set search query and filter
  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterBeneficiaries();
  }

  /// Add new beneficiary
  Future<bool> addBeneficiary(BeneficiaryModel beneficiary) async {
    try {
      await DatabaseService.addBeneficiary(beneficiary);
      await loadBeneficiaries();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add beneficiary: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Update existing beneficiary
  Future<bool> updateBeneficiary(BeneficiaryModel beneficiary) async {
    try {
      await DatabaseService.updateBeneficiary(beneficiary);
      await loadBeneficiaries();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update beneficiary: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Delete beneficiary
  Future<bool> deleteBeneficiary(String id) async {
    try {
      await DatabaseService.deleteBeneficiary(id);
      await loadBeneficiaries();
      Get.snackbar(
        'Success',
        'Beneficiary deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete beneficiary: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Get beneficiary by ID
  BeneficiaryModel? getBeneficiaryById(String id) {
    return beneficiaries.firstWhereOrNull((beneficiary) => beneficiary.id == id);
  }

  /// Get total beneficiaries count
  int getTotalBeneficiariesCount() {
    return beneficiaries.length;
  }
}

